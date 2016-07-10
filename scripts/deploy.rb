#!/usr/bin/env ruby
require_relative "lib/options"
require "aws-sdk"
require "pp"

module NWMedia
  AWS_CONSOLE_URI = "https://console.aws.amazon.com/opsworks/home"
  S3_URI = "https://s3.amazonaws.com"

  class Deploy
    def initialize
      @options ||= Options.parse(ARGV) { |options|
        options.s3_bucket_option "nw-deployment"
        options.ops_stack_name_option "Nichols Works"
        options.gradle_dist_folder_option File.join("build", "distributions")
        options.flags_option [ "no_s3", "no_deploy" ]
      }
      @s3 = Aws::S3::Client.new(@options.client)
      @opsworks = Aws::OpsWorks::Client.new(@options.client)
    end

    def run
      raise Aws::Errors::ServiceError.new self, "Cannot deploy to local environment" if %i| dev |.include? @options.env

      upload_archive(archive_key, archive_source)

      deploy_stack(@options.stack_name)

      puts "Complete."
    rescue Aws::Errors::ServiceError => e
      puts e.message()
    end

    def version
      @version ||= `head #{@options.project_root}/VERSION | awk '{print $2}'`.gsub!("\n", "")
    end

    def sha
      @sha ||= `git rev-parse --short HEAD`.gsub!("\n", "")
    end

    def archive_name
      @archive_name ||= "#{@options.project_name}-#{version}-#{sha}.tgz"
    end

    def archive_key
      @archive_key ||= "#{@options.env}/#{@options.project_name}/#{archive_name}"
    end

    def archive_source
      @archive_source ||= File.join(@options.project_root, @options.dist_folder, archive_name)
    end

  private
    def upload_archive(key, source)
      raise Aws::Errors::ServiceError.new self, "File not found: #{source}" unless File.exists?(source)
      put_obj = @s3.put_object(
        bucket: @options.bucket,
        key: key,
        body: File.open(source)
      ) unless @options.flags.include? "no_s3"
      puts "Uploaded archive: #{s3_uri()}"
      put_obj
    rescue Aws::Errors::ServiceError => e
      puts "Unable to upload archive to s3: #{AWS_CONSOLE_URI}"
      raise
    end

    def deploy_stack(stack_name)
      puts "Deploying Stack: #{stack_name}"
      stacks.each { |stack|
        next unless stack.name == stack_name
        pp stack if @options.debug
        deploy_app(@options.project_name, stack)
      }
    end

    def deploy_app(app_name, stack)
      puts "Deploying App: #{app_name}"
      apps(stack).each { |app|
        next unless app.shortname == app_name
        pp app if @options.debug
        update_app_uri(stack, app, s3_uri)
        deployment = create_deployment(stack, app)
        wait until status(deployment) != "running"
        puts
      }
    end

    def wait
      sleep(10)
      print "."
    end

    def status(deployment)
      return "successful" if deployment == nil
      state = @opsworks.describe_deployments(
        deployment_ids: [ deployment.deployment_id ]
      ).deployments.first.status
    rescue Aws::Errors::ServiceError => e
      puts "Unable to query deployment: #{deployment_uri(stack, deployment)}"
      raise
    end

    def stacks
      stack_block = @opsworks.describe_stacks
      stack_block.stacks
    rescue Aws::Errors::ServiceError => e
      puts "Unable to retrieve stacks: #{opswork_uri}"
      raise
    end

    def apps(stack)
      app_block = @opsworks.describe_apps(
        stack_id: stack.stack_id
      )
      raise Aws::Errors::ServiceError.new self, "No apps found." if app_block.empty?
      app_block.apps
    rescue Aws::Errors::ServiceError => e
      puts "Unable to retrieve apps: #{stack_uri(stack)}"
      raise
    end

    def update_app_uri(stack, app, uri)
      updated_app = @opsworks.update_app(
        app_id: app.app_id,
        app_source: {
          url: uri
        }
      )
      puts "App URI updated: #{app_uri(stack, app)}"
      updated_app
    rescue Aws::Errors::ServiceError => e
      puts "Unable to update app: #{app_uri(stack, app)}"
      raise
    end

    def create_deployment(stack, app)
      deployment = @opsworks.create_deployment(
        stack_id: stack.stack_id,
        app_id: app.app_id,
        command: { name: "deploy" }
      ) unless @options.flags.include? "no_deploy"
      puts "Deployment created: #{deployment_uri(stack, deployment)}"
      deployment
    rescue Aws::Errors::ServiceError => e
      puts "Unable to create deployment: #{app_uri(stack, app)}"
      raise
    end

    def s3_uri
      "#{S3_URI}/#{@options.bucket}/#{archive_key}"
    end

    def opsworks_uri
      "#{AWS_CONSOLE_URI}?region=#{@options.region}"
    end

    def stack_uri(stack)
      "#{opsworks_uri}#/stack/#{stack.stack_id}/stack"
    end

    def app_uri(stack, app)
      a_id = app && app.app_id || "null"
      "#{opsworks_uri}#/stack/#{stack.stack_id}/apps/#{a_id}"
    end

    def deployment_uri(stack, deployment)
      d_id = deployment && deployment.deployment_id || "null"
      "#{opsworks_uri}#/stack/#{stack.stack_id}/deployments/#{d_id}"
    end
  end
end

NWMedia::Deploy.new.run

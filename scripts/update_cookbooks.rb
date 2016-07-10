#!/usr/bin/env ruby
require_relative "lib/options"
require "aws-sdk"
require "pp"

module NWMedia
  AWS_CONSOLE_URI = "https://console.aws.amazon.com/opsworks/home"

  class UpdateCookbooks
    def initialize
      @options ||= Options.parse(ARGV) { |options|
        options.ops_stack_name_option "Nichols Works"
        options.flags_option [ "no_deploy" ]
      }
      @opsworks = Aws::OpsWorks::Client.new(@options.client)
    end

    def run
      deploy_stack(@options.stack_name)

      puts "Complete."
    rescue Aws::Errors::ServiceError => e
      puts e.message()
    end

  private
    def deploy_stack(stack_name)
      puts "Deploying Stack: #{stack_name}"
      stacks.each { |stack|
        next unless stack.name == stack_name
        pp stack if @options.debug
        deployment = deploy_cookbooks(stack)
        wait until status(deployment) != "running"
        puts
      }
    end

    def wait
      sleep(10)
      print "."
    end

    def status(deployment)
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

    def deploy_cookbooks(stack)
      deployment = @opsworks.create_deployment(
        stack_id: stack.stack_id,
        command: { name: "update_custom_cookbooks" }
      ) unless @options.flags.include? "no_deploy"
      puts "Deployment created: #{deployment_uri(stack, deployment)}"
      deployment
    rescue Aws::Errors::ServiceError => e
      puts "Unable to create deployment: #{app_uri(stack, app)}"
      raise
    end

    def opsworks_uri
      "#{AWS_CONSOLE_URI}?region=#{@options.region}"
    end

    def stack_uri(stack)
      "#{opsworks_uri}#/stack/#{stack.stack_id}/stack"
    end

    def deployment_uri(stack, deployment)
      d_id = deployment && deployment.deployment_id || "null"
      "#{opsworks_uri}#/stack/#{stack.stack_id}/deployments/#{d_id}"
    end
  end
end

NWMedia::UpdateCookbooks.new.run

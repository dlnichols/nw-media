CREATE OR REPLACE FUNCTION util.create_new_media_user(_name text, _email text)
RETURNS SETOF media_user AS $$
DECLARE
  _new_id UUID := gen_random_uuid();
BEGIN
  RETURN QUERY INSERT
  INTO media_user (id, name, email, created_by, last_modified_by)
  VALUES (_new_id, _name, _email, _new_id, _new_id)
  RETURNING *;
END;
$$ LANGUAGE plpgsql;

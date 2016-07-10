CREATE OR REPLACE FUNCTION util.update_last_modified_date()
RETURNS TRIGGER AS $$
BEGIN
  IF row(NEW.*) IS DISTINCT FROM row(OLD.*) THEN
    NEW.last_modified_date = timezone('utc'::text, now());
    RETURN NEW;
  ELSE
    RETURN OLD;
  END IF;
END;
$$ LANGUAGE plpgsql;

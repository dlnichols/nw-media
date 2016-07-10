package works.nichols.media.exception;

import java.util.UUID;

public class EntityNotFoundException extends RuntimeException {
  public EntityNotFoundException(String message, UUID id) {
    super(String.format("%1s %2s was not found.", message, id));
  }

  public EntityNotFoundException(String message, UUID id, Throwable throwable) {
    super(String.format("%1s %2s was not found.", message, id), throwable);
  }
}

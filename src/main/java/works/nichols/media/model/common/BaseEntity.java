package works.nichols.media.model.common;

import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.GenericGenerator;

import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.MappedSuperclass;
import java.util.UUID;

@MappedSuperclass
@EqualsAndHashCode()
@NoArgsConstructor
public abstract class BaseEntity {
  @Getter
  @Id @GeneratedValue(generator = "system-uuid")
  @GenericGenerator(name = "system-uuid", strategy = "uuid2")
  private UUID id;

  @Getter
  @Setter
  private String name;

  @Getter
  @Setter
  private String description;

  public BaseEntity(BaseEntity entity) {
    name = entity.name;
    description = entity.description;
  }

  public BaseEntity update(BaseEntity entity) {
    if (entity.name != null) { name = entity.name; }
    if (entity.description != null) { description = entity.description; }

    return this;
  }
}

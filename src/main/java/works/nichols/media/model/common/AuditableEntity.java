package works.nichols.media.model.common;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.extern.log4j.Log4j;
import org.hibernate.annotations.Type;
import org.hibernate.type.ZonedDateTimeType;
import org.springframework.data.annotation.CreatedBy;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedBy;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import javax.persistence.Column;
import javax.persistence.EntityListeners;
import javax.persistence.MappedSuperclass;
import java.time.ZonedDateTime;
import java.util.UUID;

@MappedSuperclass
@EntityListeners(AuditingEntityListener.class)
@NoArgsConstructor
@Log4j
public class AuditableEntity extends BaseEntity {
  @Getter
  @CreatedBy
  @Column(name = "created_by", updatable = false)
  private UUID createdBy;

  @Getter
  @CreatedDate
  @Type(type = "org.hibernate.type.ZonedDateTimeType")
  @Column(name = "created_date", insertable = false, updatable = false, columnDefinition = "TIMESTAMP WITH TIME ZONE")
  private ZonedDateTime createdDate;

  @Getter
  @LastModifiedBy
  @Column(name = "last_modified_by")
  private UUID lastModifiedBy;

  @Getter
  @LastModifiedDate
  @Type(type = "org.hibernate.type.ZonedDateTimeType")
  @Column(name = "last_modified_date", insertable = false, updatable = false, columnDefinition = "TIMESTAMP WITH TIME ZONE")
  private ZonedDateTime lastModifiedDate;

  public AuditableEntity(AuditableEntity entity) {
    super(entity);
  }
}

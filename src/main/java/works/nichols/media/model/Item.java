package works.nichols.media.model;

import works.nichols.media.model.common.AuditableEntity;

import lombok.extern.log4j.Log4j;
import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.DynamicInsert;
import org.hibernate.annotations.DynamicUpdate;

import javax.persistence.Entity;
import javax.persistence.Table;
import java.io.Serializable;

@Entity
@Table(name = "item")
@NoArgsConstructor
@Log4j
@DynamicInsert(true)
@DynamicUpdate(true)
public class Item extends AuditableEntity implements Serializable {
  public Item update(Item item) {
    super.update(item);

    return this;
  }
}

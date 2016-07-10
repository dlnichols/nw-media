package works.nichols.media.service;

import works.nichols.media.model.Item;
import works.nichols.media.repository.ItemRepository;
import works.nichols.media.exception.EntityNotFoundException;

import lombok.extern.log4j.Log4j;
import lombok.NonNull;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
@Log4j
public class ItemService {
  @Autowired
  private ItemRepository repository;

  ///////////////////////////////////////////////////////////////////////////
  // Create Items

  public Item add(Item item) {
    return repository.save(item);
  }

  ///////////////////////////////////////////////////////////////////////////
  // Read Items

  public Item fetch(@NonNull UUID id) throws EntityNotFoundException {
    Item item = repository.findOne(id);
    if (item == null) {
      throw new EntityNotFoundException("Item", id);
    }

    return item;
  }

  public Page<Item> fetch(Pageable pageable) {
    return repository.findAll(pageable);
  }

  ///////////////////////////////////////////////////////////////////////////
  // Update Items

  public Item update(@NonNull UUID id, Item item_changes) throws EntityNotFoundException {
    Item item = repository.findOne(id);
    if (item == null) {
      throw new EntityNotFoundException("Item", id);
    }

    item.update(item_changes);
    return repository.save(item);
  }

  ///////////////////////////////////////////////////////////////////////////
  // Delete Items

  public Item delete(@NonNull UUID id) throws EntityNotFoundException {
    Item item = repository.findOne(id);
    if (item == null) {
      throw new EntityNotFoundException("Item", id);
    }

    repository.delete(item);
    return item;
  }
}

package works.nichols.media.controller;

import works.nichols.media.model.Item;
import works.nichols.media.service.ItemService;

import lombok.extern.log4j.Log4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.PathVariable;

import java.util.UUID;

@RestController
@Log4j
public class ItemController {
  @Autowired
  private ItemService service;

  ///////////////////////////////////////////////////////////////////////////
  // Create Items

  @RequestMapping(
    method = RequestMethod.POST,
    value = "/items",
    consumes = "application/json",
    produces = "application/json")
  public Item addItem(@RequestBody Item item) {
    return service.add(item);
  }

  ///////////////////////////////////////////////////////////////////////////
  // Read Items

  @RequestMapping(
      method = RequestMethod.GET,
      value = "/items/{id}",
      produces = "application/json")
  public Item getItem(@PathVariable UUID id) {
    return service.fetch(id);
  }

  @RequestMapping(
      method = RequestMethod.GET,
      value = "/items",
      produces = "application/json")
  public Page<Item> getItems(
      @RequestParam(value = "archived", defaultValue = "false") boolean archived,
      @RequestParam(value = "page", defaultValue = "0") int page,
      @RequestParam(value = "size", defaultValue = "50") int size,
      @RequestParam(value = "sort_column", defaultValue = "name") String sort_column,
      @RequestParam(value = "sort_order", defaultValue = "ASC") String sort_order) {
    size = Math.min(size, 250);

    Sort sort = new Sort(
      new Sort.Order(
        Sort.Direction.fromStringOrNull(sort_order),
        sort_column
      )
    );

    return service.fetch(new PageRequest(page, size, sort));
  }

  ///////////////////////////////////////////////////////////////////////////
  // Update Items

  @RequestMapping(
      method = RequestMethod.PUT,
      value = "/items/{id}",
      consumes = "application/json",
      produces = "application/json")
  public Item updateItem(@PathVariable UUID id,
                         @RequestBody Item item) {
    return service.update(id, item);
  }

  ///////////////////////////////////////////////////////////////////////////
  // Delete Items

  @RequestMapping(
      method = RequestMethod.DELETE,
      value = "/items/{id}",
      produces = "application/json")
  public Item deleteItem(@PathVariable UUID id) {
    return service.delete(id);
  }
}

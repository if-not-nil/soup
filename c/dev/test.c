#include "../soup.h"
#include <stdio.h>

soup_arr(int);
soup_arr_display(soup_int_arr, "%d");
int test_int_arr() {
  soup_int_arr arr = soup_int_arr_init(1);
  printf("on init: size %lu\n", arr.capacity);
  soup_int_arr_push(&arr, 2);
  soup_int_arr_push(&arr, 8);
  soup_int_arr_push(&arr, 9);
  printf("on pushing 3 items: size %lu, count %lu\n", arr.capacity, arr.count);
  soup_int_arr_print(&arr);
  soup_int_arr_push(&arr, 7);
  printf("on pushing 4 items: size %lu, count %lu\n", arr.capacity, arr.count);
  soup_int_arr_print(&arr);
  printf("before shrink: size %lu\n", arr.capacity);
  soup_int_arr_shrink(&arr);
  printf("after shrink: size %lu\n", arr.capacity);
  return 0;
}

soup_arr_named(char, string);
soup_arr_display(string, "%c");
int test_string() {
  string arr = string_init(8);
  string_push(&arr, 'a');
  printf("%s\n", arr.items);
  string_append(&arr, "hello world", 12);
  string_push(&arr, 'b');
  string_push(&arr, '\0');
  string_pop(&arr, 2);
  string_ensure_terminated(&arr);
  printf("%s\n", arr.items);
  return 0;
}

int main(int argc, char *argv[]) {
  test_string();
  return 0;
}

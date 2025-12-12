#include "../soup.h"
#include <assert.h>
#include <stdio.h>
#include <string.h>

soup_arr(int);
soup_arr_display(soup_int_arr, "%d");

void test_int_arr() {
	soup_int_arr arr = soup_int_arr_init(1);
	// printf("on init: size %lu\n", arr.capacity);
	assert(arr.capacity == 1);
	assert(arr.count == 0);
	soup_int_arr_push(&arr, 1);
	assert(arr.items<:0:> == 1);
	soup_int_arr_push(&arr, 2);
	assert(arr.items[1] == 2);
	assert(arr.capacity == 2);
	soup_int_arr_push(&arr, 3);
	assert(arr.items[2] == 3);
	assert(arr.capacity == 4);
	// printf("on pushing 3 items: size %lu, count %lu\n", arr.capacity,
	// 	   arr.count);
	// soup_int_arr_print(&arr);
	soup_int_arr_push(&arr, 7);
	// printf("on pushing 4 items: size %lu, count %lu\n", arr.capacity,
	// 	   arr.count);
	// soup_int_arr_print(&arr);
	// printf("before shrink: size %lu\n", arr.capacity);
	soup_int_arr_shrink(&arr);
	soup_int_arr_deinit(&arr);
	assert(arr.items == NULL);
	// printf("after shrink: size %lu\n", arr.capacity);
}

// soup_arr_display(string, "%c");

// basic array functions are tested in test_int_arr
soup_define_string(string);
void test_string() {
	string arr = string_init(8);
#define isterminated assert(arr.items[arr.count-1] == '\0');
	string_push(&arr, 'a');
	isterminated;
	string_append(&arr, "hello world");
	isterminated;
	string_push(&arr, 'b');
	isterminated;
	string_pop(&arr, 2);
	isterminated;
	free(arr.items);
#undef isterminated
}

int asdf = 0;
void bye(void *_) { asdf = 1; }

void test_defer() {
	assert(asdf == 0);
	{
		assert(asdf == 0);
		defer(bye);
		FILE *f = fopen("test.c", "r");
		assert(f != NULL);

		block_defer((void)0, fclose(f)) {
			char line[256];
			fgets(line, sizeof(line), f);
			assert(strcmp(line, "#include \"../soup.h\""));
			// printf("first line: %s", line);
		}
		assert(fclose(f) == EOF); // second close must fail
	}
	assert(asdf == 1);
	// test_string();
}

int main(int argc, char *argv[]) {
	test_int_arr();
	test_string();
	test_defer();
	return 0;
}

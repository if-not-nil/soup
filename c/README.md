# soup.c
```c
"dynamic array macros";
    soup_arr(int);              // for a generic type, as soup_int_arr
    void int_arrays() {
        soup_int_arr arr = soup_int_arr_init(1);
        soup_int_arr_push(&arr, 9);
        soup_int_arr_print(&arr);
        printf("before shrink: size %lu\n", arr.capacity);
        soup_int_arr_shrink(&arr);
        printf("after shrink: size %lu\n", arr.capacity);
        return 0;
    }
"named array macros";
    soup_arr_named(char, string);
    void strings() {
        string arr = string_init(8);
        string_push(&arr, 'a');
        printf("%s\n", arr.items);
        string_append(&arr, "hello world", 12);
        string_push(&arr, 'b');
        string_push(&arr, '\0');
        string_pop(&arr, 2);
        string_ensure_terminated(&arr);
        free(arr.items);
    }

"defer and block_defer macros";
    void bye(void *_) { printf("bye!\n"); }

	defer(bye); // simple defer function
	FILE *f = fopen("test.c", "r");

    // classic block defer
	block_defer((void)0, fclose(f)) { 
		char line[256];
		fgets(line, sizeof(line), f); // file is still open here
		printf("first line: %s", line);
    } // and gets closed here
	assert(fclose(f) == EOF); // second close will fail
```
## usage
you're supposed to directly use the header file
```wget https://raw.githubusercontent.com/if-not-nil/soup/refs/heads/main/c/soup.h```
and then import it


#ifndef INCLUDE_SOUP
#define INCLUDE_SOUP

#include <memory.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>

static inline void die(int pred, const char *message) {
	if (pred) {
		fprintf(stderr, "error: %s", message);
		exit(1);
	}
}

/// ============== ///
/// dynamic arrays ///
/// ============== ///

#define _soup_arr_struct(type, sname)                                          \
	typedef struct {                                                           \
		type *items;                                                           \
		size_t count;                                                          \
		size_t capacity;                                                       \
	} sname;

#define _soup_arr_init_fn(type, sname)                                         \
	static inline sname sname##_init(size_t init_capacity) {                   \
		type *address = (type *)malloc(sizeof(type) * init_capacity);          \
		die(address == NULL, "malloc failed");                                 \
		sname ret = {                                                          \
			.capacity = init_capacity,                                         \
			.count = 0,                                                        \
			.items = address,                                                  \
		};                                                                     \
		return ret;                                                            \
	}

#define _soup_arr_shrink_fn(type, name)                                        \
	static inline void name##_shrink(name *arr) {                              \
		if (arr->count == 0) {                                                 \
			free(arr->items);                                                  \
			arr->items = NULL;                                                 \
			arr->capacity = 0;                                                 \
		} else {                                                               \
			arr->capacity = arr->count;                                        \
			arr->items = realloc(arr->items, sizeof(type) * arr->capacity);    \
			die(arr->items == NULL, "realloc failed");                         \
		}                                                                      \
	}

#define _soup_arr_push_fn(type, name)                                          \
	static inline void name##_push(name *arr, type value) {                    \
		if (arr->count >= arr->capacity) {                                     \
			size_t new_capacity = arr->capacity ? arr->capacity * 2 : 1;       \
			arr->items = realloc(arr->items, sizeof(type) * new_capacity);     \
			die(arr->items == NULL, "realloc failed");                         \
			arr->capacity = new_capacity;                                      \
		}                                                                      \
		arr->items[arr->count] = value;                                        \
		arr->count++;                                                          \
	}

#define _soup_arr_append_fn(type, name)                                        \
	static inline void name##_append(name *arr, type *values, size_t n) {      \
		if (arr->count + n >= arr->capacity) {                                 \
			size_t new_capacity = arr->capacity ? arr->capacity : 1;           \
			while (new_capacity < arr->count + n)                              \
				new_capacity *= 2;                                             \
			arr->items = realloc(arr->items, sizeof(type) * new_capacity);     \
			die(arr->items == NULL, "realloc failed");                         \
			arr->capacity = new_capacity;                                      \
		}                                                                      \
		memcpy(arr->items + arr->count, values, n * sizeof(type));             \
		arr->count += n;                                                       \
	}

#define _soup_arr_pop_fn(type, name)                                           \
	static inline void name##_pop(name *arr, size_t n) {                       \
		if (n > arr->count) {                                                  \
			arr->count = 0;                                                    \
			return;                                                            \
		};                                                                     \
		arr->count -= n;                                                       \
	}

#define _soup_arr_ensure_terminated_fn(type, name)                             \
	static inline void name##_ensure_terminated(name *arr) {                   \
		if (arr->items[arr->count] == '\0') {                                  \
			return;                                                            \
		}                                                                      \
		if (arr->count >= arr->capacity) {                                     \
			size_t new_capacity = arr->capacity ? arr->capacity * 2 : 1;       \
			arr->items = realloc(arr->items, sizeof(type) * new_capacity);     \
			die(arr->items == NULL, "realloc failed");                         \
			arr->capacity = new_capacity;                                      \
		}                                                                      \
		arr->items[arr->count] = '\0';                                         \
		arr->count++;                                                          \
	}

#define soup_arr_display(name, fmt)                                            \
	static inline void name##_print(name *arr) {                               \
		printf("[");                                                           \
		for (size_t i = 0; i < arr->count; i++) {                              \
			printf(fmt, arr->items[i]);                                        \
			if (i + 1 < arr->count) {                                          \
				printf(", ");                                                  \
			};                                                                 \
		};                                                                     \
		printf("]\n");                                                         \
	}

#define soup_arr_named(type, name)                                             \
	_soup_arr_struct(type, name);                                              \
	_soup_arr_init_fn(type, name);                                             \
	_soup_arr_append_fn(type, name);                                           \
	_soup_arr_shrink_fn(type, name);                                           \
	_soup_arr_ensure_terminated_fn(type, name);                                \
	_soup_arr_pop_fn(type, name);                                              \
	_soup_arr_push_fn(type, name);

// soup_arr_def(int, soup_, _arr);
#define soup_arr(type) soup_arr_named(type, soup_##type##_arr)

#endif // INCLUDE_BROTH

#ifndef INCLUDE_SOUP
#define INCLUDE_SOUP

#ifdef __cplusplus
extern "C" {
#endif

#include <memory.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>

#if defined(__GNUC__) || defined(__clang__)
// idk why clangd tells me both are defined
#define _soup_boilerplate __attribute__((unused)) static inline
#elif defined(_MSC_VER)
// just suppresses the warning
#define _soup_boilerplate __inline
#else
// only tcc doesn't have this so this is far enough
#if defined(__cplusplus) && __cplusplus >= 201703L
#define _soup_boilerplate [[maybe_unused]] static inline
#else
#define _soup_boilerplate static inline
#endif
#endif

_soup_boilerplate void die(int pred, const char *message) {
	if (pred) {
		fprintf(stderr, "error: %s", message);
		exit(1);
	}
}

/*
 * dynamic arrays!
 *
 * semi-easily and semi-safely auto manages your void pointers to
 * anything semi-automatically
 */

#define _soup_arr_struct(type, sname)                                          \
	typedef struct {                                                           \
		type *items;                                                           \
		size_t count;                                                          \
		size_t capacity;                                                       \
	} sname;

#define _soup_arr_init_fn(type, sname)                                         \
	_soup_boilerplate sname sname##_init(size_t init_capacity) {               \
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
	_soup_boilerplate void name##_shrink(name *self) {                         \
		if (self->count == 0) {                                                \
			free(self->items);                                                 \
			self->items = NULL;                                                \
			self->capacity = 0;                                                \
		} else {                                                               \
			self->capacity = self->count;                                      \
			self->items = realloc(self->items, sizeof(type) * self->capacity); \
			die(self->items == NULL, "realloc failed");                        \
		}                                                                      \
	}

#define _soup_arr_clone_fn(type, name)                                         \
	_soup_boilerplate name name##_clone(const name *src) {                     \
		name dst;                                                              \
		dst.count = src->count;                                                \
		dst.capacity = src->capacity;                                          \
		dst.items = malloc(sizeof(type) * dst.capacity);                       \
		die(dst.items == NULL, "malloc failed");                               \
		memcpy(dst.items, src->items, sizeof(type) * src->count);              \
		return dst;                                                            \
	}

#define _soup_arr_push_fn(type, name)                                          \
	_soup_boilerplate void name##_push(name *self, type value) {               \
		if (self->count >= self->capacity) {                                   \
			size_t new_capacity = self->capacity ? self->capacity * 2 : 1;     \
			self->items = realloc(self->items, sizeof(type) * new_capacity);   \
			die(self->items == NULL, "realloc failed");                        \
			self->capacity = new_capacity;                                     \
		}                                                                      \
		self->items[self->count] = value;                                      \
		self->count++;                                                         \
	}

#define _soup_arr_append_fn(type, name)                                        \
	_soup_boilerplate void name##_append(name *self, type *values, size_t n) { \
		if (self->count + n >= self->capacity) {                               \
			size_t new_capacity = self->capacity ? self->capacity : 1;         \
			while (new_capacity < self->count + n)                             \
				new_capacity *= 2;                                             \
			self->items = realloc(self->items, sizeof(type) * new_capacity);   \
			die(self->items == NULL, "realloc failed");                        \
			self->capacity = new_capacity;                                     \
		}                                                                      \
		memcpy(self->items + self->count, values, n * sizeof(type));           \
		self->count += n;                                                      \
	}
#define _soup_arr_deinit_fn(type, name)                                        \
	_soup_boilerplate void name##_deinit(name *self) {                         \
		if (self->items)                                                       \
			free(self->items);                                                 \
		self->items = NULL;                                                    \
		self->count = 0;                                                       \
		self->capacity = 0;                                                    \
	}
#define _soup_arr_pop_fn(type, name)                                           \
	_soup_boilerplate void name##_pop(name *self, size_t n) {                  \
		if (n > self->count) {                                                 \
			self->count = 0;                                                   \
			return;                                                            \
		};                                                                     \
		self->count -= n;                                                      \
	}

#define soup_arr_display(name, fmt)                                            \
	_soup_boilerplate void name##_print(name *self) {                          \
		printf("[");                                                           \
		for (size_t i = 0; i < self->count; i++) {                             \
			printf(fmt, self->items[i]);                                       \
			if (i + 1 < self->count) {                                         \
				printf(", ");                                                  \
			};                                                                 \
		};                                                                     \
		printf("]\n");                                                         \
	}

#define soup_arr_named(type, name)                                             \
	_soup_arr_struct(type, name);                                              \
	_soup_arr_init_fn(type, name);                                             \
	_soup_arr_deinit_fn(type, name);                                           \
	_soup_arr_clone_fn(type, name);                                            \
	_soup_arr_append_fn(type, name);                                           \
	_soup_arr_shrink_fn(type, name);                                           \
	_soup_arr_pop_fn(type, name);                                              \
	_soup_arr_push_fn(type, name);

// soup_arr_def(int, soup_, _arr);
#define soup_arr(type) soup_arr_named(type, soup_##type##_arr)

/*
 * strings!
 *
 * auto null terminated dynamic arrays of chars
 */

#define _soup_string_struct(name)                                              \
	typedef struct {                                                           \
		char *items;                                                           \
		size_t count;                                                          \
		size_t capacity;                                                       \
	} name;

#define _soup_string_grow(name)                                                \
	_soup_boilerplate void name##_grow(name *s) {                              \
		size_t newcap = s->capacity ? s->capacity * 2 : 2;                     \
		char *newbuf = realloc(s->items, newcap);                              \
		die(!newbuf, "realloc failed");                                        \
		s->items = newbuf;                                                     \
		s->capacity = newcap;                                                  \
	}

#define _soup_string_init_fn(name)                                             \
	_soup_boilerplate name name##_init(size_t cap) {                           \
		if (cap < 1)                                                           \
			cap = 1;                                                           \
		/* +1 for null terminator */                                           \
		char *buf = malloc(cap + 1);                                           \
		die(!buf, "malloc failed");                                            \
		buf[0] = '\0';                                                         \
		name s = {.items = buf, .count = 1, .capacity = cap + 1};              \
		return s;                                                              \
	}

#define _soup_string_deinit_fn(name)                                           \
	_soup_boilerplate void name##_deinit(name *s) {                            \
		if (s->items)                                                          \
			free(s->items);                                                    \
		s->items = NULL;                                                       \
		s->count = 0;                                                          \
		s->capacity = 0;                                                       \
	}

#define _soup_string_clone_fn(name)                                            \
	_soup_boilerplate name name##_clone(const name *src) {                     \
		name dst;                                                              \
		dst.count = src->count;                                                \
		dst.capacity = src->capacity;                                          \
		dst.items = malloc(dst.capacity);                                      \
		die(!dst.items, "malloc failed");                                      \
		memcpy(dst.items, src->items, src->count); /* includes '\0' */         \
		return dst;                                                            \
	}

#define _soup_string_from_cstr_fn(name)                                        \
	_soup_boilerplate name name##_from_cstr(const char *cstr) {                \
		size_t n = strlen(cstr);                                               \
		size_t cap = 1;                                                        \
		while (cap < n + 1)                                                    \
			cap *= 2;                                                          \
		char *buf = malloc(cap);                                               \
		die(!buf, "malloc failed");                                            \
		memcpy(buf, cstr, n + 1); /* include '\0' */                           \
		name s = {.items = buf, .count = n + 1, .capacity = cap};              \
		return s;                                                              \
	}

#define _soup_string_push_fn(name)                                             \
	_soup_boilerplate void name##_push(name *s, char ch) {                     \
		if (s->count + 1 > s->capacity)                                        \
			name##_grow(s);                                                    \
		s->items[s->count - 1] = ch; /* overwrite existing terminator */       \
		s->items[s->count] = '\0';                                             \
		s->count++;                                                            \
	}

#define _soup_string_append_fn(name)                                           \
	_soup_boilerplate void name##_append(name *s, const char *src) {           \
		size_t n = strlen(src);                                                \
		size_t needed =                                                        \
			s->count + n; /* +1 for final terminator already in count */       \
		if (needed > s->capacity) {                                            \
			size_t newcap = s->capacity;                                       \
			while (newcap < needed)                                            \
				newcap *= 2;                                                   \
			char *newbuf = realloc(s->items, newcap);                          \
			die(!newbuf, "realloc failed");                                    \
			s->items = newbuf;                                                 \
			s->capacity = newcap;                                              \
		}                                                                      \
		memcpy(s->items + s->count - 1, src, n + 1); /* copies '\0' */         \
		s->count += n;                                                         \
	}

#define _soup_string_pop_fn(name)                                              \
	_soup_boilerplate void name##_pop(name *s, size_t n) {                     \
		if (n >= s->count - 1) { /* remove everything but leave '\0' */        \
			s->count = 1;                                                      \
			s->items[0] = '\0';                                                \
			return;                                                            \
		}                                                                      \
		s->count -= n;                                                         \
		s->items[s->count - 1] = '\0';                                         \
	}

#define _soup_string_shrink_fn(name)                                           \
	_soup_boilerplate void name##_shrink(name *s) {                            \
		if (s->count == 0) {                                                   \
			free(s->items);                                                    \
			s->items = NULL;                                                   \
			s->capacity = 0;                                                   \
			return;                                                            \
		}                                                                      \
		char *newbuf = realloc(s->items, s->count);                            \
		die(!newbuf, "realloc failed");                                        \
		s->items = newbuf;                                                     \
		s->capacity = s->count;                                                \
	}

#define soup_define_string(name)                                               \
	_soup_string_struct(name);                                                 \
	_soup_string_grow(name);                                                   \
	_soup_string_init_fn(name);                                                \
	_soup_string_from_cstr_fn(name);                                           \
	_soup_string_deinit_fn(name);                                              \
	_soup_string_clone_fn(name);                                               \
	_soup_string_push_fn(name);                                                \
	_soup_string_append_fn(name);                                              \
	_soup_string_pop_fn(name);                                                 \
	_soup_string_shrink_fn(name);
#endif

/*
 * defer macro
 */

// typedef void (*_defer_func)(void *);
// static inline void _defer_cleanup(void *fn) {
// 	_defer_func f = *(_defer_func *)fn;
// 	f(NULL);
// }

typedef void (*_defer_func)(void *);

static inline void _defer_cleanup(void *fn) {
	_defer_func f = *(_defer_func *)fn;
	f(NULL);
}

#define defer(fn)                                                              \
	__attribute__((                                                            \
		cleanup(_defer_cleanup))) _defer_func _defer_##__COUNTER__ = fn

#define block_defer(start, end) for (int _i_ = (start, 0); !_i_; _i_++, end)

#ifdef __cplusplus
}
#endif

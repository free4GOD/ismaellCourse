/*
# A string is a palindrome if it reads the same in both directions.
# Only alphanumeric characters are considered, any other character is
# ignored/skipped.

# New task:
# Now we're comparing Zettabyte+ data records for palindrome?ness.
# A function, called GetChunk(offset start, offset end) returns the
# desired portion (pointer), GetLength() returns the length of the data record.
# Chunk_end - Chunk_begin = 4MB
*/

#include <ctype.h> // isalnum()
#include <stddef.h> // size_t

#define CHUNK_SIZE (4 * 1024 * 1024)

struct chunk {
	size_t	pos, len;
	ssize_t	step;
	const char * begin, * end;
	const char * p;
};

void init_chunk(struct chunk * c, size_t pos, size_t len) {
	c->pos = pos;
	c->len = len;
	c->begin = GetChunk(pos, len);
	c->end = c->begin + len;
	c->step = (0 == pos) ? CHUNK_SIZE : -CHUNK_SIZE;
	c->p = (0 == pos) ? c->begin : c->end - 1;
}

void next_chunk(struct chunk * c) {
	if (c->len != CHUNK_SIZE) {
		c->pos -= c->len;
		c->len = CHUNK_SIZE;
	} else {
		c->pos += c->step;
	}
	c->begin = GetChunk(c->pos, CHUNK_SIZE);
	c->end = c->begin + CHUNK_SIZE;
}

void next_char(struct chunk *c) {
	if (c->step < 0) {
		c->p--;
		if (c->p < c->begin) {
			next_chunk(c);
			c->p = c->end;
		}
	} else {
		c->p++;
		if (c->p >= c->end) {
			next_chunk(c);
			c->p = c->begin;
		}
	}
}

bool chunk_pos_less_or_eq(struct chunk *a, struct chunk *b) {
	return (a->pos < b->pos) || (a->pos == b->pos && a->p < b->p);
}

bool is_palindrome(void) {
	struct chunk * i, * j;

	init_chunk(i, 0, CHUNK_SIZE);
	size_t len = GetLength();
	size_t tail = len % CHUNK_SIZE;
	if (tail) {
		init_chunk(j, len - tail, tail);
	} else {
		init_chunk(j, len - CHUNK_SIZE, CHUNK_SIZE);
	}

	while (chunk_pos_less_or_eq(i, j)) {
		while (!isalnum(*i->p) && chunk_pos_less_or_eq(i, j))
			next_char(i);
		while (!isalnum(*j->p) && chunk_pos_less_or_eq(i, j))
			next_char(j);
		if (toupper(*i->p) != toupper(*j->p))
			return false;
		next_char(i);
		next_char(j);
	}
	return true;
}




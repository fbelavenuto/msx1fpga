/* Getopt for GNU.
   NOTE: getopt is now part of the C library, so if you don't know what
   "Keep this file name-space clean" means, talk to roland@gnu.ai.mit.edu
   before changing it!

   Copyright (C) 1987, 88, 89, 90, 91, 92, 93, 94, 95
   	Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify it
   under the terms of the GNU General Public License as published by the
   Free Software Foundation; either version 2, or (at your option) any
   later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.  */


//#include <stdio.h>
//#include <stdlib.h>
#include <string.h>


/* This version of `getopt' appears to the caller like standard Unix `getopt'
   but it behaves differently for the user, since it allows the user
   to intersperse the options with the other arguments.

   As `getopt' works, it permutes the elements of ARGV so that,
   when it is done, all the options precede everything else.  Thus
   all application programs are extended to handle flexible argument order.

   GNU application programs can use a third alternative mode in which
   they can distinguish the relative order of options and other arguments.  */

#include "getopt.h"

/* The next char to be scanned in the option-element
   in which the last option character we returned was found.
   This allows us to pick up the scan where we left off.

   If this is zero, or a null string, it means resume the scan
   by advancing to the next ARGV-element.  */

static char *nextchar;
static char c;
static char *temp;

/* Index in ARGV of the next element to be scanned.
   This is used for communication to and from the caller
   and for communication between successive calls to `getopt'.

   On entry to `getopt', zero means this is the first call; initialize.

   When `getopt' returns EOF, this is the index of the first of the
   non-option elements that the caller should itself scan.

   Otherwise, `optind' communicates from one call to the next
   how much of ARGV has been scanned so far.  */

/* XXX 1003.2 says this must be 1 before any call.  */
static int optind = -1;

/* Set to an option character which was unrecognized.
   This must be initialized on some systems to avoid linking in the
   system's own getopt implementation.  */

static unsigned char optopt = '?';

/* Handle permutation of arguments.  */

/* Describe the part of ARGV that contains non-options that have
   been skipped.  `first_nonopt' is the index in ARGV of the first of them;
   `last_nonopt' is the index after the last of them.  */

static int first_nonopt;
static int last_nonopt;

/* For communication from `getopt' to the caller.
   When `getopt' finds an option that takes an argument,
   the argument value is returned here.
   Also, when `ordering' is RETURN_IN_ORDER,
   each non-option ARGV-element is returned here.  */

char *optarg = NULL;

/* Scan elements of ARGV (whose length is ARGC) for option characters
   given in OPTSTRING.

   If an element of ARGV starts with '-', and is not exactly "-" or "--",
   then it is an option element.  The characters of this element
   (aside from the initial '-') are option characters.  If `getopt'
   is called repeatedly, it returns successively each of the option characters
   from each of the option elements.

   If 'getopt' finds another option character, it returns that character,
   updating `optind' and `nextchar' so that the next call to `getopt' can
   resume the scan with the following option character or ARGV-element.

   If there are no more option characters, `getopt' returns `EOF'.
   Then `optind' is the index in ARGV of the first ARGV-element
   that is not an option.  (The ARGV-elements have been permuted
   so that those that are not options now come last.)

   OPTSTRING is a string containing the legitimate option characters.
   If an option character is seen that is not listed in OPTSTRING,
   return '?' after printing an error message.  If you set `opterr' to
   zero, the error message is suppressed but we still return '?'.

   If a char in OPTSTRING is followed by a colon, that means it wants an arg,
   so the following text in the same ARGV-element, or the text of the following
   ARGV-element, is returned in `optarg'.  Two colons mean an option that
   wants an optional arg; if there is text in the current ARGV-element,
   it is returned in `optarg', otherwise `optarg' is set to zero.
  */

unsigned char getopt(int argc, char *argv[], const char optstring[])
{
	optarg = NULL;

	if (optind == -1) {
		first_nonopt = last_nonopt = optind = 0;
		nextchar = NULL;
		optind = 0;
	}

	if (nextchar == NULL || *nextchar == '\0') {
		/* Advance to the next ARGV-element.  */

		/* The special ARGV-element `--' means premature end of options.
		   Skip it like a null option,
		   then exchange with previous non-options as if it were an option,
		   then skip everything else like a non-option.  */

		if (optind != argc && !strcmp(argv[optind], "--")) {
			optind++;
			if (first_nonopt == last_nonopt) {
				first_nonopt = optind;
			}
			last_nonopt = argc;
			optind = argc;
		}

		/* If we have done all the ARGV-elements, stop the scan
		   and back over any non-options that we skipped and permuted.  */

		if (optind == argc) {
			/* Set the next-arg-index to point at the non-options
			  that we previously skipped, so the caller will digest them.  */
			if (first_nonopt != last_nonopt) {
				optind = first_nonopt;
			}
			return 255;
		}

		/* If we have come to a non-option and did not permute it,
		   either stop the scan or describe it to the caller and pass it by.  */

		if ((argv[optind][0] != '-' || argv[optind][1] == '\0')) {
			optarg = argv[optind++];
			return 1;
		}

		/* We have found another option-ARGV-element.
		   Skip the initial punctuation.  */
		nextchar = argv[optind] + 1 ;
	}

	/* Decode the current option-ARGV-element.  */

	/* Look at and handle the next short option-character.  */
	c = *nextchar;
	++nextchar;
	temp = strchr(optstring, c);

	/* Increment `optind' when we start to process its last character.  */
	if (*nextchar == '\0') {
		++optind;
	}

	if (temp == NULL || c == ':') {
		optopt = c;
		return '?';
	}
	if (temp[1] == ':') {
		if (temp[2] == ':') {
			/* This is an option that accepts an argument optionally.  */
			if (*nextchar != '\0') {
				optarg = nextchar;
				optind++;
			} else {
				optarg = NULL;
			}
			nextchar = NULL;
		} else {
			/* This is an option that requires an argument.  */
			if (*nextchar != '\0') {
				optarg = nextchar;
				/* If we end this ARGV-element by taking the rest as an arg,
				   we must advance to the next element now.  */
				optind++;
			} else if (optind == argc) {
				optopt = c;
				if (optstring[0] == ':') {
					c = ':';
				} else {
					c = '?';
				}
			} else {
				/* We already incremented `optind' once;
				   increment it again when taking next ARGV-elt as argument.  */
				optarg = argv[optind++];
			}
			nextchar = NULL;
		}
	}
	return c;
}

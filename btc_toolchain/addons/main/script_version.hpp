#ifndef SCRIPT_VERSION_HPP
#define SCRIPT_VERSION_HPP

#define MAJOR 1
#define MINOR 4
#define PATCH 3// `#define PATCHLVL` can also be used
#define BUILD 0// Optional
#define VERSION MAJOR.MINOR
#define VERSION_STR MAJOR.MINOR.PATCH
#define VERSION_AR MAJOR, MINOR, PATCH
#define REQUIRED_VERSION 2.20
#define REQUIRED_CBA_VERSION {3,18,4}

#endif


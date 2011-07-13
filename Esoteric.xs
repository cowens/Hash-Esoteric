#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include "const-c.inc"

/* if numbers have more than 100 digits, well, fuck */
#define STRBUFSIZE 101

SV* keys_by_bucket(HV* h) {
	I32    i, buckets;
	HE**   array;
	HE*    cur;
	AV*    ret = newAV();
	AV*    bucket_items;

	array = HvARRAY(h);
	
	buckets = array == (HE**)NULL ? 0 : HvMAX(h);

	for (i = 0; i < buckets; i++) {
		bucket_items = newAV();
		for (cur = array[i]; cur != (HE*)NULL; cur = HeNEXT(cur)) {
			av_push(bucket_items, newSVhek(HeKEY_hek(cur)));
		}
		av_push(ret, newRV_noinc((SV*)bucket_items));
	}
	return newRV_noinc((SV*)ret);
}

SV* keys_by_collisions(HV* h) {
	I32    i, collision_num, buckets;
	HE**   array;
	HE*    cur;
	HV*    keys_by_collisions = newHV();
	SV**   keys; 
	char   collisions[STRBUFSIZE];

	array = HvARRAY(h);
	
	buckets = array == (HE**)NULL ? 0 : HvMAX(h);

	for (i = 0; i < buckets; i++) {
		collision_num = 0;
		for (cur = array[i]; cur != (HE*)NULL; cur = HeNEXT(cur)) {
			collision_num++;
		}
		/* FIXME I don't know if %ld is proper for an I32,
		   but it shuts the compiler up*/
		snprintf(collisions, STRBUFSIZE, "%ld", (long)collision_num);
		for (cur = array[i]; cur != (HE*)NULL; cur = HeNEXT(cur)) {
			keys = hv_fetch(keys_by_collisions, collisions,
				strlen(collisions), 1); 
			if (!SvROK(*keys)) {
				sv_setsv(*keys, newRV_noinc((SV*)newAV()));
			}
			av_push((AV*)SvRV(*keys), newSVhek(HeKEY_hek(cur)));
		}
	}
	return newRV_noinc((SV*)keys_by_collisions);
}

MODULE = Hash::Esoteric		PACKAGE = Hash::Esoteric		

INCLUDE: const-xs.inc

PROTOTYPES: DISABLE

SV* keys_by_bucket(h)
	HV* h;

SV* keys_by_collisions(h)
	HV* h;

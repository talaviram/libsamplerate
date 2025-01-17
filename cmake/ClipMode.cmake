include (CheckCSourceRuns)

macro (CLIP_MODE)

    set (CLIP_MODE_POSITIVE_MESSAGE "Target processor clips on positive float to int conversion")
    set (CLIP_MODE_NEGATIVE_MESSAGE "Target processor clips on negative float to int conversion")

    message (STATUS "Checking processor clipping capabilities...")

    if (CMAKE_CROSSCOMPILING OR NOT HAVE_LRINT)

        set (CLIP_MSG "disabled")
        set (CPU_CLIPS_POSITIVE FALSE CACHE BOOL ${CLIP_MODE_POSITIVE_MESSAGE})
        set (CPU_CLIPS_NEGATIVE FALSE CACHE BOOL ${CLIP_MODE_NEGATIVE_MESSAGE})

    else ()

        check_c_source_runs (
        "
        #include <math.h>
        int main (void)
        {   double  fval ;
            int k, ival ;

            fval = 1.0 * 0x7FFFFFFF ;
            for (k = 0 ; k < 100 ; k++)
            {   ival = (lrint (fval)) >> 24 ;
                if (ival != 127)
                    return 1 ;

                fval *= 1.2499999 ;
                } ;

                return 0 ;
            }
        "
        CPU_CLIPS_POSITIVE)

        check_c_source_runs (
        "
        #include <math.h>
        int main (void)
        {   double  fval ;
            int k, ival ;

            fval = -8.0 * 0x10000000 ;
            for (k = 0 ; k < 100 ; k++)
            {   ival = (lrint (fval)) >> 24 ;
                if (ival != -128)
                    return 1 ;

                fval *= 1.2499999 ;
                } ;

                return 0 ;
            }
        "
        CPU_CLIPS_NEGATIVE)

        if (CPU_CLIPS_POSITIVE AND CPU_CLIPS_NEGATIVE)
            set (CLIP_MSG "both")
        elseif (CPU_CLIPS_POSITIVE)
            set (CLIP_MSG "positive")
        elseif (CPU_CLIPS_NEGATIVE)
            set (CLIP_MSG "negative")
        else ()
            set (CLIP_MSG "none")
        endif ()

    endif ()

    message (STATUS "Checking processor clipping capabilities... ${CLIP_MSG}")

endmacro ()

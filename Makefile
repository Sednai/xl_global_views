EXTENSION = xl_global_views        # the extensions name
DATA = xl_global_views--0.0.1.sql  # script files to install
REGRESS = xl_global_views_test     # our test script file (without extension)

# postgres build stuff
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

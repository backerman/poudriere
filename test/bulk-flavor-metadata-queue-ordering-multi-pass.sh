# first depends on a specific flavor
# second depends on the default flavor
# The order matters here since listed_ports does a sort -u. The specific
# FLAVOR dependency MUST come first to hit the bug.
#
#
# bulk-flavor-metadata-queue-ordering.sh Not enough, consider:
# + firefox depends on databases/py-sqlite3
#  -> gqueue
# + zenmap depends on databases/py-sqlite3@py27
#  -> mqueue
#  -> fqueue
# + devel/foo depends on devel/bar@flavor
#  -> mqueue
#  -> gqueue
# Now we find that py-sqlite3 depends on devel/bar (default)
#  -> gqueue
#   -> ERROR: Already looked up
#
# devel-dep-FOO depends on freebsd-release-manifests@FOO
# zzzz depends on freebsd-release-manifests (DEFAULT)
# yyyy depends on devel/foo@FLAV
# 2nd pass:
# freebsd-release-manifests@FOO depends on devel/foo (DEFAULT)
LISTPORTS="ports-mgmt/poudriere-devel-dep-FOO ports-mgmt/zzzz ports-mgmt/yyyy"
OVERLAYS="omnibus"
. common.bulk.sh

do_bulk -n ${LISTPORTS}
assert 0 $? "Bulk should pass"

EXPECTED_QUEUED="misc/foo misc/foo@FLAV misc/freebsd-release-manifests misc/freebsd-release-manifests@FOO ports-mgmt/pkg ports-mgmt/poudriere-devel-dep-FOO ports-mgmt/yyyy ports-mgmt/zzzz"
EXPECTED_LISTED="ports-mgmt/poudriere-devel-dep-FOO ports-mgmt/yyyy ports-mgmt/zzzz"

assert_bulk_queue_and_stats

#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <customer-name>"
    echo "  Example: $0 acme"
    exit 1
fi

CUSTOMER="$1"
CUSTOMER_DIR="$SCRIPT_DIR/customers/$CUSTOMER"
GPO_DIR="$CUSTOMER_DIR/gpo"
SHARED_GPO="$SCRIPT_DIR/shared/gpo"

if [[ -d "$CUSTOMER_DIR" ]]; then
    echo "Error: customers/$CUSTOMER already exists"
    exit 1
fi

# Create folder structure
mkdir -p "$GPO_DIR/group_vars"

# Copy templates
cp "$SCRIPT_DIR/templates/customer/gpo/ansible.cfg"        "$GPO_DIR/ansible.cfg"
cp "$SCRIPT_DIR/templates/customer/gpo/inventory.yml"      "$GPO_DIR/inventory.yml"
cp "$SCRIPT_DIR/templates/customer/gpo/group_vars/all.yml" "$GPO_DIR/group_vars/all.yml"

# Create symlinks to shared playbooks, tasks, and files
for playbook in "$SHARED_GPO"/playbook-*.yml; do
    playbook_name="$(basename "$playbook")"
    ln -s "../../../shared/gpo/$playbook_name" "$GPO_DIR/$playbook_name"
done
ln -s "../../../shared/gpo/tasks" "$GPO_DIR/tasks"
ln -s "../../../shared/gpo/files" "$GPO_DIR/files"

echo "Created customers/$CUSTOMER"
echo ""
echo "Next steps:"
echo "  1. Edit customers/$CUSTOMER/gpo/inventory.yml  — add hosts"
echo "  2. Edit customers/$CUSTOMER/gpo/group_vars/all.yml — add domain, DC, backup path, OUs"
echo "  3. cd customers/$CUSTOMER/gpo && ansible-playbook playbook-gpo-check.yml"

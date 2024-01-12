data "google_organization" "benchsci_org" {
  domain = "benchsci.com"
}

resource "google_organization_iam_custom_role" "data-eng-role" {
  role_id     = "DataTeamRole"
  org_id      = data.google_organization.benchsci_org.org_id
  title       = "Data Team Role"
  description = "Role to allow data team to view GCS buckets in Data account"
  permissions = [
    "iam.roles.create",
    "iam.roles.delete",
    "storage.buckets.get",
    "storage.buckets.create",
    "storage.buckets.delete"
    ]
}
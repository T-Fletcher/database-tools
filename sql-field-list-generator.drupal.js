// Generate SQL query for targeting and replacing values based on their field type and bundle

// Copy and run in the browser console at <site>/admin/reports/fields

// Used in conjunction with `globally-find-and-replace-target-string.mariadb.sql`

// Check these before running! The backticks are important for the SQL syntax!
let targetStr =
  '<a data-entity-substitution="canonical" data-entity-type="media" data-entity-uuid=';
let replaceStr =
  '<a data-entity-substitution="media" data-entity-type="media" data-entity-uuid=';
let targetFieldFormat = `'html'`;
let test = "Text (formatted";
let query = "";

jQuery(".responsive-enabled tbody tr").each(function () {
  let title = this.children[0].innerHTML;
  let bundle = this.children[1].innerHTML;
  let format = this.children[2].innerHTML;
  let bundles = [];

  if (!format.includes(test)) {
    return;
  } else {
    switch (bundle) {
      case "block":
        bundles = ["block", "block_revision"];
        break;
      case "media":
        bundles = ["media", "media_revision"];
        break;
      case "node":
        bundles = ["node", "node_revision"];
        break;
      case "paragraph":
        bundles = ["paragraph", "paragraph_revision"];
        break;
      case "taxonomy_term":
        bundles = ["taxonomy_term", "taxonomy_term_revision"];
        break;
      default:
        break;
    }
  }

  // Assumes database tables follow Drupal entity naming conventions e.g. entityType__fieldName
  // The 'bundle' column in the database table is implied by the way we generate the field names
  // *** The quote marks around the replaceLinks() vars are required for SQL formatting!!! ***
  for (let i = 0; i < bundles.length; i++) {
    let tableName = `${bundles[i]}__${title}`,
      fieldName = `${title}_value`,
      fieldFormat = `${title}_format`;
    query += `CALL replaceLinks('${tableName}', '${fieldName}', '${fieldFormat}', '${targetStr}', '${replaceStr}');\n`;
  }
});

// Copy to clipboard instead of log result, as this can get long
//console.log(query);
copy(query);

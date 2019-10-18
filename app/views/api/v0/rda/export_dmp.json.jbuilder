json.prettify!

json.dmp do
  json.title  @plan.title
  json.description  @plan.description if @plan.description.present?
  json.language @plan_info[:language]
  json.created @plan.created_at
  json.modified @plan.updated_at
  json.ethicalIssuesExist  @plan_info[:ethical_issues]
  # TODO: add in other ethical issues fields
  # TODO: Map answers to question with theme "Ethics & privacy"
  # json.ethicalIssuesDescription

  json.contact do
    json.name @plan_info[:contact][:name]
    json.mail @plan_info[:contact][:mail]
    json.contact_id do
      json.contact_id @plan_info[:contact][:id]
      json.contact_id_type @plan_info[:contact][:id_type]
    end
  end

  # TODO: make this an array with a single item
  json.dataset do
    json.personal_data "unknown"
    json.sensitive_date "unknown"
    json.title @plan.title # NOTE: this is a bad mapping
    json.type "dataset" # NOTE: this is a bad mapping
    json.description @plan_info[:dataset][:desc]
  end

end

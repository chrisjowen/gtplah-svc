defmodule GtpLah.UserIntegrationController do
  use GtpLah.BaseController, schema: GtpLah.Schema.UserIntegration
  plug(GtpLah.ClearOrderBy)
end

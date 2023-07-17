defmodule Modules do
  alias GtpLah

  @modules [
    {GtpLah.Schema.Message, []},
    {GtpLah.Schema.MessageLink, []},
    {GtpLah.Schema.Link, []},
    {GtpLah.Schema.Feedback, []},
    {GtpLah.Schema.UserIntegration, []},
    {Scrivener.Page, []},
    {GtpLah.Schema.User, [:password, :clear_password, :salt]}
  ]

  def modules, do:  @modules
end


Enum.map(Modules.modules, fn {module, strip} ->
  defimpl Jason.Encoder, for: module do
    def encode(schema, options) do
     Util.MapUtil.from_struct(schema, unquote(Modules.modules))
      |>  Jason.Encoder.Map.encode(options)
    end
  end
end)

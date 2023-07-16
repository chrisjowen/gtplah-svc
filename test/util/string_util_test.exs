defmodule GtpLah.Util.StringUtilTest do
  use GtpLah.DataCase
  alias Util.StringUtil

  test "Can extract url with http" do
    assert StringUtil.extract_urls("http://www.google.com") == ["http://www.google.com"]
  end

  test "Can extract url with https" do
    assert StringUtil.extract_urls("https://www.google.com") == ["https://www.google.com"]
  end

  test "Can extract url with no http" do
    assert StringUtil.extract_urls("www.google.com") == ["http://www.google.com"]
  end

  test "Can extract url with no wwww" do
    assert StringUtil.extract_urls("google.com") == ["http://google.com"]
  end

  test "Can extract url with text" do
    assert StringUtil.extract_urls("Look this is google www.google.com") == ["http://www.google.com"]
  end
  test "Should work" do
    assert StringUtil.extract_urls("Simple text message http://www.google.com") == ["http://www.google.com"]
  end

  test "Can extract none .com work" do
    assert StringUtil.extract_urls("checkout https://www.crowdsolve.ai/") == ["https://www.crowdsolve.ai/"]
  end


  test "Can extract tags" do
    assert StringUtil.extract_tags("checkout https://www.crowdsolve.ai/ #awesome #cool") == ["awesome", "cool"]
  end

  test "Can extract empty tags" do
    assert StringUtil.extract_tags("checkout https://www.crowdsolve.ai/") == []
  end


  test "wtf" do
    tags = ["OAuth 2.0", "scopes", "Google APIs", "Authorization", "Google for Developers"]
    link_params =
    %{
      description: "This document lists the OAuth 2.0 scopes that you ",
      title: "OAuth 2.0 Scopes for Google APIs &nbsp;|&nbsp; Authorization &nbsp;|&nbsp; Google for Developers",
      url: "https://developers.google.com/identity/protocols/oauth2/scopes",
      created_by_id: 1,
      tags: []
    }

    Map.put(link_params, :tags, tags) |> IO.inspect()
  end

end

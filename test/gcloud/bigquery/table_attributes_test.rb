# Copyright 2015 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"
require "json"
require "uri"

describe Gcloud::Bigquery::Table, :attributes, :mock_bigquery do
  # Create a table object with the project's mocked connection object
  let(:table_id) { "my_table" }
  let(:table_name) { "My Table" }
  let(:description) { "This is my table" }
  let(:table_hash) { random_table_small_hash "my_table", table_id, table_name }
  let(:table_full_json) { random_table_hash("my_table", table_id, table_name, description).to_json }
  let(:table) { Gcloud::Bigquery::Table.from_gapi table_hash,
                                                  bigquery.connection }

  it "gets full data for created_at" do
    mock_connection.get "/bigquery/v2/projects/#{project}/datasets/#{table.dataset_id}/tables/#{table.table_id}" do |env|
      [200, {"Content-Type"=>"application/json"},
       table_full_json]
    end

    table.created_at.must_be_close_to Time.now, 10

    # A second call to attribute does not make a second HTTP API call
    table.created_at
  end

  it "gets full data for expires_at" do
    mock_connection.get "/bigquery/v2/projects/#{project}/datasets/#{table.dataset_id}/tables/#{table.table_id}" do |env|
      [200, {"Content-Type"=>"application/json"},
       table_full_json]
    end

    table.expires_at.must_be_close_to Time.now, 10

    # A second call to attribute does not make a second HTTP API call
    table.expires_at
  end

  it "gets full data for modified_at" do
    mock_connection.get "/bigquery/v2/projects/#{project}/datasets/#{table.dataset_id}/tables/#{table.table_id}" do |env|
      [200, {"Content-Type"=>"application/json"},
       table_full_json]
    end

    table.modified_at.must_be_close_to Time.now, 10

    # A second call to attribute does not make a second HTTP API call
    table.modified_at
  end

  it "gets full data for schema" do
    mock_connection.get "/bigquery/v2/projects/#{project}/datasets/#{table.dataset_id}/tables/#{table.table_id}" do |env|
      [200, {"Content-Type"=>"application/json"},
       table_full_json]
    end

    table.schema.must_be_kind_of Hash
    table.schema.keys.must_include "fields"
    table.fields.must_equal table.schema["fields"]
    table.headers.must_equal ["name", "age", "score", "active"]

    # A second call to attribute does not make a second HTTP API call
    table.schema
  end

  def self.attr_test attr, val
    define_method "test_#{attr}" do
      mock_connection.get "/bigquery/v2/projects/#{project}/datasets/#{table.dataset_id}/tables/#{table.table_id}" do |env|
        [200, {"Content-Type"=>"application/json"},
         table_full_json]
      end

      table.send(attr).must_equal val

      # A second call to attribute does not make a second HTTP API call
      table.send(attr)
    end
  end

  attr_test :description, "This is my table"
  attr_test :etag, "etag123456789"
  attr_test :api_url, "http://googleapi/bigquery/v2/projects/test-project/datasets/my_table/tables/my_table"
  attr_test :bytes_count, 1000
  attr_test :rows_count, 100
  attr_test :location, "US"

end

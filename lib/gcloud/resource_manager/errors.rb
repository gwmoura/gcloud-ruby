#--
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

require "gcloud/errors"

module Gcloud
  module ResourceManager
    ##
    # Base Resource Manager exception class.
    class Error < Gcloud::Error
    end

    ##
    # Raised when an API call is not successful.
    class ApiError < Error
      ##
      # The code of the error.
      attr_reader :code

      ##
      # The errors encountered.
      attr_reader :errors

      def initialize message, code, errors = [] #:nodoc:
        super message
        @code   = code
        @errors = errors
      end

      def self.from_response resp #:nodoc:
        if resp.data? && resp.data["error"]
          from_response_data resp.data["error"]
        else
          from_response_status resp
        end
      end

      def self.from_response_data error #:nodoc:
        new error["message"], error["code"], error["errors"]
      end

      def self.from_response_status resp #:nodoc:
        if resp.status == 404
          new "#{resp.error_message}: #{resp.request.uri.request_uri}",
              resp.status
        else
          new resp.error_message, resp.status
        end
      end
    end
  end
end

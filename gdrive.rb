module ProgressScraper
  class GDrive
    attr_accessor :session

    def initialize
      prepare_auth_client
      load_auth_page
      retrieve_auth_code
      @auth_client.fetch_access_token!

      access_token = @auth_client.access_token
      @session = GoogleDrive.login_with_oauth(access_token)
    end

    def prepare_auth_client
      client_secrets = Google::APIClient::ClientSecrets.load
      @auth_client = client_secrets.to_authorization
      @auth_client.update!(
        scope: [
          "https://www.googleapis.com/auth/drive",
          "https://spreadsheets.google.com/feeds/"
        ],
        redirect_uri: 'urn:ietf:wg:oauth:2.0:oob'
      )
    end

    def load_auth_page
      auth_uri = @auth_client.authorization_uri.to_s
      Launchy.open(auth_uri)
    end

    def retrieve_auth_code
      print 'Paste the code from the auth response page: '.colorize(:blue)
      @auth_client.code = $stdin.gets
    end

    def spreadsheet(key)
      @session.spreadsheet_by_key key
    end
  end
end

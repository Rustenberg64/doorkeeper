# frozen_string_literal: true

Doorkeeper::OpenidConnect.configure do
  issuer do |resource_owner, application|
    'issuer string'
  end

  # 本当は秘密鍵は環境変数に入れるべきだが、ここでは簡単のためにそのまま記述している
  signing_key <<~KEY
    -----BEGIN RSA PRIVATE KEY-----
    MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCYayO/MF/DPjLJ
    whY0jpOyIBLy/vJ5pn1fh7r/G9YHQfEYx4G6SECXycSiJCWD1XOK7wn5UrOefCkL
    5kqvh4hwWjPNQLiv/tiG86283erXlAeKb3y5fF9ceIilcqhebkHYtHNSesRT9OOh
    f9LK8EZ7YtIjodyoXN0qcacF9mTtG/8NItkexQFjDHFf0qZ9VpHHCq8+NuEsCKgm
    4g2J6SxFV8NUex8EOujkMtvKPajYyC6E+Q2dAIq7WMJqGfLwGz2P+lK367zFkNvX
    Alvb8XSap3quuknj8ebZV2E1LL841odAbXjzRocaEQzxu4DZKRlPQ5G/Rxt87Wac
    H3yw1IHhAgMBAAECggEACwPMeLUmE9s2BWb4KYKCQaBYGOUmyyF73wBVRGQTwsDX
    tnA4kP3xY7wfmzjHLfCqNx37l7U2fjC/203LE5tVAgrqwnMNGx7s2/fWlEG/W9FP
    /YeoDlQ4JLEgmEBMfaKJ3KonHrdON+OzOEkfXS4hvH9Rlg9M/dfUMzc1GFUMSdGc
    YQ2RKfJF0nnVLkKz3EdD0GH7ERIyEkjCQo2A4afe8qFtkOdFNWzXEL3FmjuUG+Gp
    oRQNNdw8eZnqjFNvPXIdc4ZuagW+JOTXSuXIwAwCS0magJTHhc4BkUNnIl6hhrK0
    W8e9f8G/AXOWHzqCV1d5FXgBLbc0dhpvphjUPLoqyQKBgQC8EE3Rz3JqeVpmEdtb
    NyWfhAuCq2Jxe7NcXkdnAtkOKCnJDZty3ZOLazMqXQC/OMmN3szI2GQsE2Zwy9TU
    MKfFCuXS5wlOfdA6fCqU7jUSy9SzJA0JhLsFM7ugEQbpDYksxVU0Wz4vUapW17J/
    vdUgnczlFa72BfmysHUrVZhprQKBgQDPenPG6j1QgWlYNOtMA5CtPPaJmoAEYyo2
    zbTxALrPCR1tU7Ox6j0k5xW1slMnlHU1V7KLq9JgctQDt0wNoPk122F0bnS//aE3
    RgvyijPtTzrSvRCvDFU2K39IlMc0tzHWfH6sM/gDk6+2u7mf/fqOIe6r2UrqDb63
    1BvYZMVnhQKBgFEWrpdC3VCvlpzgIjcIZj6LjvL+tum7rrCrLhpqjfCevLWmGlrC
    03WP+XXQuBu7fpyfbqlDNJ4Ul10XZmM/v3ckpcf0On0PnpM5Kpsgwt2h6cp8RurN
    wl4R2lrAPLyMS5N0WrLCjOOWUN41DxApaBYyNECqws/t76Zuk3bl51vZAoGBAIwr
    elSEo+/jvjvtZJnyPqgLa7QDQUG1jSuBRiEcERkWW18lEV29lpl71VrvouY2kgj7
    upBKANNQQJRSHXuHqVYNZIW4qf+bZnNlS2UMoZBN2rvNJ5xbhKYYNOHgQcUHjxAN
    A7drVL9141xc70d72u5zVj+bidUefB7NmhJT4lnRAoGADhT4wkKPCWSwm4TDy6dq
    dzawJ1tGs3QC9gs6Z46C1u1ByfyTIpuwUJjHhSZFULnTqAetfIW2d/wTWl07Onuu
    pFnd0XOZq0geVy+U4gC5XA9gr/qQlM4Kboczcrj1njqnQfOsHwTqS5XY3VCg+1Jw
    NQKEonJaYSvIVd1PybwcN1k=
    -----END RSA PRIVATE KEY-----
  KEY

  subject_types_supported [:pairwise]

  resource_owner_from_access_token do |access_token|
    # Example implementation:
    User.find_by(id: access_token.resource_owner_id)
  end

  auth_time_from_resource_owner do |resource_owner|
    # Example implementation:
    # resource_owner.current_sign_in_at
  end

  reauthenticate_resource_owner do |resource_owner, return_to|
    # Example implementation:
    # store_location_for resource_owner, return_to
    # sign_out resource_owner
    # redirect_to new_user_session_url
  end

  # Depending on your configuration, a DoubleRenderError could be raised
  # if render/redirect_to is called at some point before this callback is executed.
  # To avoid the DoubleRenderError, you could add these two lines at the beginning
  #  of this callback: (Reference: https://github.com/rails/rails/issues/25106)
  #   self.response_body = nil
  #   @_response_body = nil
  select_account_for_resource_owner do |resource_owner, return_to|
    # Example implementation:
    # store_location_for resource_owner, return_to
    # redirect_to account_select_url
  end

  subject do |resource_owner, application|
    # Example implementation:
    # resource_owner.id

    # or if you need pairwise subject identifier, implement like below:
    Digest::SHA256.hexdigest("#{resource_owner.id}#{URI.parse(application.redirect_uri).host}#{'your_secret_salt'}")
  end

  # Protocol to use when generating URIs for the discovery endpoint,
  # for example if you also use HTTPS in development
  # protocol do
  #   :https
  # end

  # Expiration time on or after which the ID Token MUST NOT be accepted for processing. (default 120 seconds).
  # expiration 600

  # Example claims:
  # claims do
  #   normal_claim :_foo_ do |resource_owner|
  #     resource_owner.foo
  #   end

  #   normal_claim :_bar_ do |resource_owner|
  #     resource_owner.bar
  #   end
  # end
end

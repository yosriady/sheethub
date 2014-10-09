Paperclip::Attachment.default_options[:url] = ':s3_domain_url'
Paperclip::Attachment.default_options[:path] = '/:class/:hash/:style/:filename'
Paperclip::Attachment.default_options[:s3_permissions] = :private

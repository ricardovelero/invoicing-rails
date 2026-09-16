include Carmen

# Carmen 1.1.3 has no upstream fix for Rails 8.1's deprecated mb_chars.
# Preserve its UTF-8 coercion and normalization using native String methods.
Carmen::Querying.module_eval do
  private

  def normalise_name(name)
    name.dup.force_encoding(Encoding::UTF_8).downcase.unicode_normalize(:nfkc)
  end
end

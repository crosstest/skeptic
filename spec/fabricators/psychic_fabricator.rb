# Fabricates test manifests (.omnitest.yaml files)

Fabricator(:psychic, from: Omnitest::Psychic) do
  initialize_with do
    transients = @_transient_attributes.to_hash
    transients[:name] ||= 'my_sample_project'
    transients[:cwd] ||= "sdks/#{transients[:name]}"
    @_klass.new transients
  end # Hash based initialization
  transient :name
  transient :cwd
end

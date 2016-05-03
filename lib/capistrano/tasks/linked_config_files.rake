# Upload stage separated configs and merge them with linked_files
namespace :linked_files do
  namespace :upload do
    # Upload the config files that have been separated by stage.
    after :files, :stage_configs do
      on roles :web do
        stage = fetch(:stage)
        fetch(:config_files,[]).each do |file|
          upload! File.join("upload", "#{stage}-#{file}"), "#{shared_path}/#{file}"
        end
      end
    end

    # merge config_files into linked_files so the symlinks get made
    after :stage_configs, :configs_to_links do
      on roles :web do
        merged_files = fetch(:config_files,[]).concat(fetch(:linked_files)).uniq
        set :linked_files, merged_files
      end
    end
  end
end

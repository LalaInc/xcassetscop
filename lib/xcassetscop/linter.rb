# frozen_string_literal: true

require 'json'
require_relative './template_rendering_intent'
require_relative './image_scale'

module XCAssetsCop
  module Linter
    def self.get_file_name(contents_json)
      contents_json&.dig('images')&.first&.dig('filename')
    end

    def self.file_name_matches_asset_name(contents_json, file_path)
      asset_name = file_path.split('/').select { |str| str.include? '.imageset' }.first.split('.').first
      file_name = get_file_name(contents_json).split('.').first
      return [] if file_name == asset_name

      ["Expected asset name and file name to be the same, got:\nAsset name: #{asset_name}\nFile name: #{file_name}"]
    end

    def self.validate_image_scale(contents_json, expected)
      validate_params expected, ImageScale.available_values
      case contents_json&.dig('images')&.size
      when 1
        image_scale = ImageScale::SINGLE
      when 3
        image_scale = ImageScale::INDIVIDUAL
      when 4
        image_scale = ImageScale::INDIVIDUAL_AND_SINGLE
      else
        raise StandardError, "Couldn't figure out the image scale"
      end
      return [] if image_scale == expected

      file_name = get_file_name contents_json
      ["Expected #{file_name} scale to be '#{expected}', got '#{image_scale}' instead"]
    end

    def self.validate_template_rendering_intent(contents_json, expected)
      validate_params expected, TemplateRenderingIntent.available_values
      template_rendering_intent = contents_json&.dig('properties')&.dig('template-rendering-intent') || TemplateRenderingIntent::DEFAULT
      return [] if template_rendering_intent == expected

      file_name = get_file_name contents_json
      ["Expected #{file_name} to be rendered as '#{expected}', got '#{template_rendering_intent}' instead"]
    end

    def self.validate_params(param, valid_params)
      return true if valid_params.include? param

      raise StandardError, "'#{param}' is not a valid parameter.\nValid parameters: #{valid_params.join(', ')}"
    end

    def self.validate_file_extension(contents_json, expected)
      file_name = get_file_name(contents_json)
      file_extension = file_name.split('.').last
      return [] if expected == file_extension

      ["Expected #{file_name} type to be #{expected}, got #{file_extension} instead"]
    end

    def self.lint_file(file_path, config = nil)
      file = File.read file_path
      contents_json = JSON.parse file

      template_rendering_intent = config&.dig('template_rendering_intent')
      image_scale = config&.dig('image_scale')
      same_file_and_asset_name = config&.dig('same_file_and_asset_name') || false
      file_extension = config&.dig('file_extension')

      errors = []

      errors += validate_template_rendering_intent(contents_json, template_rendering_intent) if template_rendering_intent
      errors += validate_image_scale(contents_json, image_scale) if image_scale
      errors += file_name_matches_asset_name(contents_json, file_path) if same_file_and_asset_name
      errors += validate_file_extension(contents_json, file_extension) if file_extension

      errors
    end

    def self.lint_files(paths, config)
      errors = []
      paths.each do |path|
        errors += lint_file(path, config)
      end
      puts errors
    end
  end
end

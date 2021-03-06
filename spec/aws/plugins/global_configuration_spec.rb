require 'spec_helper'

module Aws
  module Plugins
    describe GlobalConfiguration do

      def plugin(&block)
        Class.new(Seahorse::Client::Plugin, &block)
      end

      before(:each) do
        api = Seahorse::Model::Api.new
        api.metadata['service_class_name'] = 'Svc'
        api.version = '2013-01-01'
        Aws.add_service(:Svc, [api])
        Aws::Svc.add_plugin(GlobalConfiguration)
        Aws::Svc.add_plugin(plugin { option(:property, 'plugin-default') })
        allow(Aws).to receive(:config).and_return({})
      end

      after(:each) do
        # to silence warnings about Svc getting redefined each pass
        Aws.send(:remove_const, :Svc)
      end

      it 'does not interfere with plugins and their defaults' do
        expect(Aws.svc.config.property).to eq('plugin-default')
      end

      it 'gives priority to Aws.config over plugin defaults' do
        Aws.config[:property] = 'aws-default'
        expect(Aws.svc.config.property).to eq('aws-default')
      end

      it 'gives priority to Aws.config[:svc] over Aws.config' do
        Aws.config[:property] = 'aws-default'
        Aws.config[:svc] = { property: 'svc-default' }
        expect(Aws.svc.config.property).to eq('svc-default')
      end

      it 'gives priority to constructor options over Aws.config' do
        Aws.config[:property] = 'aws-default'
        Aws.config[:svc] = { property: 'svc-default' }
        expect(Aws.svc(property: 'arg').config.property).to eq('arg')
      end

      it 'ignores configuration for others services in Aws.config' do
        Aws.config[:property] = 'aws-default'
        Aws.config[:svc] = { property: 'svc-default' }
        Aws.config[:s3] = { property: 's3-default' }
        expect(Aws.svc.config.property).to eq('svc-default')
      end

    end
  end
end

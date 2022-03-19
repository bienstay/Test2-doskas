# Uncomment the next line to define a global platform for your project
  platform :ios, '12.0'

target 'Test2' do
  use_frameworks!

  pod 'Firebase/Auth'
  pod 'Firebase/Database'
  pod 'Firebase/Storage'
  pod 'Firebase/Functions'
  pod 'Firebase/Messaging'

  pod 'Kingfisher', '~> 7.0'
  pod 'IBPCollectionViewCompositionalLayout'
  pod 'MessageKit'

  post_install do |installer|
   installer.pods_project.targets.each do |target|
     target.build_configurations.each do |config|
       if config.name == 'Debug'
         config.build_settings['OTHER_SWIFT_FLAGS'] = ['$(inherited)', '-Onone']
         config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-O'
         config.build_settings['SWIFT_COMPILATION_MODE'] = 'singlefile'
       else
         config.build_settings['SWIFT_COMPILATION_MODE'] = 'wholemodule'
       end
     end
   end
  end

end

Pod::Spec.new do |s|
  s.name                  = 'CCNStatusItem'
  s.version               = '0.4.0'
  s.summary               = 'CCNStatusItem is a subclass of NSObject for presenting a NSStatusItem with a custom Popover Window.'
  s.homepage              = 'https://github.com/phranck/CCNStatusItem'
  s.author                = { 'Frank Gregor' => 'phranck@cocoanaut.com' }
  s.source                = { :git => 'https://github.com/phranck/CCNStatusItem.git', :tag => s.version.to_s }
  s.osx.deployment_target = '10.10'
  s.requires_arc          = true
  s.source_files          = 'CCNStatusItem/*.{h,m}'
  s.license               = { :type => 'MIT' }
end

class InitialThemes < ActiveRecord::Migration

  class Theme < ApplicationRecord
  end

  def up
    default = Theme.new(name: 'Default', css_file: 'runtime')
    default.footer = <<-DEFAULT

		<p class="footer-txt">Copyright &copy; 2018 <a href="http://concord.org/">The Concord Consortium</a>. All rights reserved. This activity is licensed under a <a href="http://creativecommons.org/licenses/by/3.0/">Creative Commons Attribution 3.0 Unported License</a>. The software is licensed under <a href="http://opensource.org/licenses/BSD-2-Clause">Simplified BSD</a>, <a href="http://opensource.org/licenses/MIT">MIT</a> or <a href="http://opensource.org/licenses/Apache-2.0">Apache 2.0</a> licenses. Please provide attribution to the Concord Consortium and the URL <a href="http://concord.org">http://concord.org</a>.</p>

		<p class="footer-txt">This Next-Generation Molecular Workbench activity was developed with a grant from <a href="http://www.google.org/">Google.org</a>. The original <a href="http://mw.concord.org/modeler/">Classic Molecular Workbench</a> was supported by a series of grants from the <a href="http://nsf.gov/">National Science Foundation</a>.</p>

DEFAULT
    default.save
    has = Theme.new(name: 'HAS National Geographic', css_file: 'theme-has-ngs')
    has.save
    mw = Theme.new(name: 'NextGen MW', css_file: 'theme-mw')
    mw.footer = <<-MW

		<p class="footer-txt">Copyright &copy; 2018 <a href="http://concord.org/">The Concord Consortium</a>. All rights reserved. This activity is licensed under a <a href="http://creativecommons.org/licenses/by/3.0/">Creative Commons Attribution 3.0 Unported License</a>. The software is licensed under <a href="http://opensource.org/licenses/BSD-2-Clause">Simplified BSD</a>, <a href="http://opensource.org/licenses/MIT">MIT</a> or <a href="http://opensource.org/licenses/Apache-2.0">Apache 2.0</a> licenses. Please provide attribution to the Concord Consortium and the URL <a href="http://concord.org">http://concord.org</a>.</p>

		<p class="footer-txt">This Next-Generation Molecular Workbench activity was developed with a grant from <a href="http://www.google.org/">Google.org</a>. The original <a href="http://mw.concord.org/modeler/">Classic Molecular Workbench</a> was supported by a series of grants from the <a href="http://nsf.gov/">National Science Foundation</a>.</p>

MW
    mw.save
  end

  def down
  end
end

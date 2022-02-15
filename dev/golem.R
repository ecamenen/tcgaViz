library(golem)
create_golem(path)
set_golem_options()
use_recommended_tests()
use_recommended_deps()
remove_favicon()

use_utils_ui()
use_utils_server()

shinyAppTemplate(path, "all")

# add_dockerfile()
# add_dockerfile_shinyproxy()

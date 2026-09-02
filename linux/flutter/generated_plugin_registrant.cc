//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <pose_detection/pose_detection_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) pose_detection_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "PoseDetectionPlugin");
  pose_detection_plugin_register_with_registrar(pose_detection_registrar);
}

#
# This source file is part of the FA2021 open source project
#
# SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
#
# SPDX-License-Identifier: MIT
#

import json
import sys

with open('/buoy/available_sensors.json') as in_file:
    sensors = json.loads(in_file.read())
sensor_type = int(sys.argv[1])
out_file_name = sys.argv[2]
result = 1 if sensor_type in sensors else 0
with open('/result/' + out_file_name, 'w') as out_file:
    out_file.write(str(result))

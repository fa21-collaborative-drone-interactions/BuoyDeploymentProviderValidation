import json
import sys

with open('/buoy/available_sensors.json') as in_file:
    sensors = json.loads(in_file.read())
sensor_type = int(sys.argv[1])
out_file_name = sys.argv[2]
result = 1 if sensor_type in sensors else 0
with open('/result/' + out_file_name, 'w') as out_file:
    out_file.write(str(result))

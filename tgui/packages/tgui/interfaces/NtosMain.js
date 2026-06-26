import { useBackend } from '../backend';
import { Box, Button, Flex, Icon, NoticeBox } from '../components';
import { NtosWindow } from '../layouts';

const ProgramButton = (props, context) => {
  const { act } = useBackend(context);
  const { program, ...rest } = props;
  return (
    <Flex
      align="center"
      style={{
        'border-bottom': '1px solid rgba(64, 98, 138, 0.15)',
        padding: '3px 0',
      }}>
      <Flex.Item grow={1}>
        <Button
          fluid
          color="transparent"
          style={{
            'text-align': 'left',
            padding: '8px 6px',
            'border-radius': '6px',
            transition: 'all 0.15s ease',
          }}
          icon={program.icon || 'window-maximize'}
          content={
            <Box inline ml={1}>
              <Box inline bold>
                {program.desc}
              </Box>
              <Box inline ml={1} fontSize="0.8rem" opacity={0.4}>
                {program.name}
              </Box>
            </Box>
          }
          onClick={() =>
            act('PC_runprogram', {
              name: program.name,
            })
          }
        />
      </Flex.Item>
      {!!program.running && (
        <Flex.Item mr={1}>
          <Box
            style={{
              display: 'inline-block',
              width: '8px',
              height: '8px',
              'border-radius': '50%',
              background: '#4f7529',
              'box-shadow': '0 0 8px rgba(79, 117, 41, 0.8)',
            }}
          />
        </Flex.Item>
      )}
      <Flex.Item>
        <Button
          color="transparent"
          icon="bookmark"
          tooltip="Set Autorun"
          tooltipPosition="left"
          selected={program.autorun}
          onClick={() =>
            act('PC_setautorun', {
              name: program.name,
            })
          }
        />
      </Flex.Item>
      {!!program.running && (
        <Flex.Item>
          <Button
            color="transparent"
            icon="times"
            tooltip="Close program"
            tooltipPosition="left"
            onClick={() =>
              act('PC_killprogram', {
                name: program.name,
              })
            }
          />
        </Flex.Item>
      )}
    </Flex>
  );
};

export const NtosMain = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    device_theme,
    programs = [],
    has_light,
    light_on,
    comp_light_color,
    removable_media,
    login = [],
    unsafe_to_shutdown,
  } = data;
  return (
    <NtosWindow
      title={
        (device_theme === 'syndicate' && 'Syndix Main Menu') ||
        'SCPOS Main Menu'
      }
      theme={device_theme}
      width={460}
      height={580}
      resizable>
      <NtosWindow.Content scrollable>
        {/* Header Logo Area */}
        <Box
          style={{
            background:
              'linear-gradient(135deg, rgba(64,98,138,0.15), rgba(0,0,0,0.2))',
            'border-radius': '10px',
            padding: '16px',
            'margin-bottom': '10px',
            'border': '1px solid rgba(64,98,138,0.2)',
            'text-align': 'center',
          }}>
          <Icon
            name={device_theme === 'syndicate' ? 'skull' : 'microchip'}
            fontSize={3}
            color={device_theme === 'syndicate' ? '#aa0000' : '#40628a'}
          />
          <Box
            mt={1}
            bold
            fontSize="1.2rem"
            color="#8BA5C4"
            letterSpacing="2px">
            {device_theme === 'syndicate' ? 'SYNDIX OS' : 'SCiPnet OS'}
          </Box>
          <Box fontSize="0.7rem" opacity={0.4} mt={0.5}>
            Next Generation Operating System
          </Box>
        </Box>

        {/* Flashlight */}
        {!!has_light && (
          <Box
            style={{
              background: 'rgba(0,0,0,0.3)',
              'border-radius': '8px',
              padding: '6px 10px',
              'margin-bottom': '6px',
            }}>
            <Flex align="center">
              <Flex.Item>
                <Button
                  icon="lightbulb"
                  selected={light_on}
                  onClick={() => act('PC_toggle_light')}>
                  Flashlight: {light_on ? 'ON' : 'OFF'}
                </Button>
              </Flex.Item>
              <Flex.Item ml={2}>
                <Button onClick={() => act('PC_light_color')}>
                  Color:
                  <Box
                    ml={1}
                    style={{
                      display: 'inline-block',
                      width: '12px',
                      height: '12px',
                      'border-radius': '50%',
                      background: comp_light_color,
                      'vertical-align': 'middle',
                      border: '1px solid rgba(255,255,255,0.2)',
                    }}
                  />
                </Button>
              </Flex.Item>
            </Flex>
          </Box>
        )}

        {/* User Login */}
        <Box
          style={{
            background: 'rgba(0,0,0,0.3)',
            'border-radius': '10px',
            padding: '10px',
            'margin-bottom': '6px',
            border: '1px solid rgba(64,98,138,0.2)',
          }}>
          <Flex align="center" justify="space-between">
            <Flex.Item>
              <Icon name="user-circle" fontSize={1.5} color="#8BA5C4" />
              <Box inline ml={1}>
                <Box bold fontSize="1.1rem">
                  {login.IDName || '---'}
                </Box>
                <Box fontSize="0.75rem" opacity={0.5}>
                  {login.IDJob || 'No ID'}
                </Box>
              </Box>
            </Flex.Item>
            <Flex.Item>
              <Button
                icon="eject"
                content="Eject"
                disabled={!login.IDName}
                onClick={() => act('PC_Eject_Disk', { name: 'ID' })}
              />
            </Flex.Item>
          </Flex>
        </Box>

        {/* Removable Media */}
        {!!removable_media && (
          <Box
            style={{
              background: 'rgba(0,0,0,0.2)',
              'border-radius': '8px',
              padding: '6px 10px',
              'margin-bottom': '6px',
            }}>
            <Flex align="center" justify="space-between">
              <Flex.Item>
                <Icon name="usb" color="#cd6500" />
                <Box inline ml={1} opacity={0.7}>
                  {removable_media}
                </Box>
              </Flex.Item>
              <Flex.Item>
                <Button
                  color="transparent"
                  icon="eject"
                  content="Eject"
                  onClick={() => act('PC_Eject_Disk')}
                />
              </Flex.Item>
            </Flex>
          </Box>
        )}

        {/* Shutdown Warning */}
        {unsafe_to_shutdown && (
          <NoticeBox danger mb={1}>
            <Icon name="exclamation-triangle" /> You may not switch this device
            off safely.
          </NoticeBox>
        )}

        {/* Programs Section */}
        <Box
          style={{
            background: 'rgba(0,0,0,0.2)',
            'border-radius': '10px',
            padding: '8px',
            border: '1px solid rgba(64,98,138,0.15)',
          }}>
          <Box
            style={{
              color: '#8BA5C4',
              'font-size': '0.75rem',
              'text-transform': 'uppercase',
              'letter-spacing': '1.5px',
              padding: '4px 8px 8px 8px',
              'border-bottom': '1px solid rgba(64,98,138,0.2)',
              'margin-bottom': '4px',
            }}>
            <Icon name="th-large" mr={1} />
            Programs
          </Box>
          {programs.length === 0 && (
            <Box textAlign="center" py={4} opacity={0.3}>
              <Icon name="search" fontSize={3} mb={1} />
              <Box>No programs available</Box>
            </Box>
          )}
          {programs.map((program) => (
            <ProgramButton key={program.name} program={program} />
          ))}
        </Box>
      </NtosWindow.Content>
    </NtosWindow>
  );
};

import { map } from 'common/collections';
import { toFixed } from 'common/math';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  LabeledList,
  NumberInput,
  Section,
  Flex,
  Icon,
} from '../components';
import { RADIO_CHANNELS } from '../constants';
import { Window } from '../layouts';

export const Radio = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    freqlock,
    frequency,
    minFrequency,
    maxFrequency,
    listening,
    broadcasting,
    command,
    useCommand,
    subspace,
    subspaceSwitchable,
  } = data;
  const tunedChannel = RADIO_CHANNELS.find(
    (channel) => channel.freq === frequency
  );
  const channels = map((value, key) => ({
    name: key,
    status: !!value,
  }))(data.channels);
  // Calculate window height
  let height = 130;
  if (subspace) {
    if (channels.length > 0) {
      height += channels.length * 24 + 10;
    } else {
      height += 30;
    }
  }
  return (
    <Window width={380} height={height} theme="ntos">
      <Window.Content
        style={{
          background:
            'linear-gradient(135deg, rgba(15,20,35,0.98), rgba(8,12,24,0.98))',
        }}>
        {/* Header */}
        <Box
          style={{
            background:
              'linear-gradient(135deg, rgba(64,98,138,0.15), rgba(0,0,0,0.2))',
            'border-radius': '10px',
            padding: '10px',
            'margin-bottom': '8px',
            border: '1px solid rgba(64,98,138,0.2)',
            'text-align': 'center',
          }}>
          <Icon name="headset" fontSize={1.5} color="#8BA5C4" />
          <Box
            mt={0.5}
            bold
            fontSize="1rem"
            color="#8BA5C4"
            letterSpacing="2px"
            style={{ 'text-transform': 'uppercase' }}>
            Radio Transceiver
          </Box>
          <Box fontSize="0.6rem" opacity={0.3}>
            SUBSPACE HEADSET
          </Box>
        </Box>

        <Section>
          <LabeledList>
            <LabeledList.Item
              label={
                <Box>
                  <Icon name="sliders-h" mr={1} />
                  Frequency
                </Box>
              }>
              {(freqlock && (
                <Box inline color="light-gray" bold fontSize="1.2rem">
                  {toFixed(frequency / 10, 1) + ' kHz'}
                </Box>
              )) || (
                <NumberInput
                  animate
                  unit="kHz"
                  step={0.2}
                  stepPixelSize={10}
                  minValue={minFrequency / 10}
                  maxValue={maxFrequency / 10}
                  value={frequency / 10}
                  format={(value) => toFixed(value, 1)}
                  onDrag={(e, value) =>
                    act('frequency', {
                      adjust: value - frequency / 10,
                    })
                  }
                />
              )}
              {tunedChannel && (
                <Box inline color={tunedChannel.color} ml={2} bold>
                  <Icon
                    name="circle"
                    color={tunedChannel.color}
                    size={0.6}
                    mr={0.5}
                  />
                  [{tunedChannel.name}]
                </Box>
              )}
            </LabeledList.Item>
            <LabeledList.Item
              label={
                <Box>
                  <Icon name="volume-up" mr={1} />
                  Audio
                </Box>
              }>
              <Flex spacing={1}>
                <Flex.Item>
                  <Button
                    textAlign="center"
                    width="42px"
                    height="22px"
                    icon={listening ? 'volume-up' : 'volume-mute'}
                    selected={listening}
                    tooltip={listening ? 'Speaker ON' : 'Speaker OFF'}
                    tooltipPosition="bottom"
                    onClick={() => act('listen')}
                  />
                </Flex.Item>
                <Flex.Item>
                  <Button
                    textAlign="center"
                    width="42px"
                    height="22px"
                    icon={broadcasting ? 'microphone' : 'microphone-slash'}
                    selected={broadcasting}
                    tooltip={broadcasting ? 'Mic ON' : 'Mic OFF'}
                    tooltipPosition="bottom"
                    onClick={() => act('broadcast')}
                  />
                </Flex.Item>
                {!!command && (
                  <Flex.Item>
                    <Button
                      ml={0.5}
                      icon="bullhorn"
                      selected={useCommand}
                      tooltip={`High volume ${useCommand ? 'ON' : 'OFF'}`}
                      tooltipPosition="bottom"
                      onClick={() => act('command')}>
                      {useCommand ? 'ON' : 'OFF'}
                    </Button>
                  </Flex.Item>
                )}
                {!!subspaceSwitchable && (
                  <Flex.Item>
                    <Button
                      ml={0.5}
                      icon="satellite-dish"
                      selected={subspace}
                      tooltip={`Subspace Tx ${subspace ? 'ON' : 'OFF'}`}
                      tooltipPosition="bottom"
                      onClick={() => act('subspace')}>
                      {subspace ? 'ON' : 'OFF'}
                    </Button>
                  </Flex.Item>
                )}
              </Flex>
            </LabeledList.Item>
            {!!subspace && (
              <LabeledList.Item
                label={
                  <Box>
                    <Icon name="layer-group" mr={1} />
                    Channels
                  </Box>
                }>
                {channels.length === 0 && (
                  <Box inline color="bad" bold>
                    <Icon name="exclamation-triangle" mr={1} />
                    No encryption keys installed.
                  </Box>
                )}
                {channels.length > 0 && (
                  <Box
                    style={{
                      background: 'rgba(0,0,0,0.3)',
                      'border-radius': '8px',
                      padding: '4px',
                    }}>
                    {channels.map((channel) => (
                      <Box key={channel.name} p={0.5}>
                        <Flex align="center">
                          <Flex.Item>
                            <Button
                              icon={
                                channel.status ? 'check-square-o' : 'square-o'
                              }
                              selected={channel.status}
                              onClick={() =>
                                act('channel', {
                                  channel: channel.name,
                                })
                              }
                            />
                          </Flex.Item>
                          <Flex.Item ml={1}>
                            <Box
                              bold
                              fontSize="0.9rem"
                              opacity={channel.status ? 1 : 0.4}>
                              {channel.name}
                            </Box>
                          </Flex.Item>
                        </Flex>
                      </Box>
                    ))}
                  </Box>
                )}
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};

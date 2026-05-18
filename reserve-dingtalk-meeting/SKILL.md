---
name: 预约钉钉会议
description: Use when the user invokes $预约会议 or asks to automatically create a DingTalk meeting from a meeting time and invited people. The skill should default the meeting title when omitted, query DingTalk room availability, choose the best available room by attendee count, create the calendar meeting, book the room, invite attendees, and return the final meeting details.
---

# 预约会议

## Canonical Invocation

Use this skill when the user writes:

`$预约会议`

Expected parameters:

- `会议时间`: date/time range or natural-language time
- `邀请人`: names, phone numbers, emails, or other DingTalk-identifiable attendee clues

Optional parameter:

- `会议名称`: use it when supplied; otherwise use the default below

## Defaults

Apply these defaults unless the user says otherwise:

- time zone: `Asia/Shanghai`
- title: `临时沟通会`
- date when only time is provided: today in `Asia/Shanghai`
- duration when no end time or duration is provided: `30 minutes`
- reminder: `15 minutes before start`
- attendee role: required participant

If the user omits both `会议时间` and `邀请人`, ask one concise question for the missing required values. If only `会议名称` is missing, do not ask; use the default title.

## Required DingTalk MCP Tools

Use MCP tools for this workflow. Do not fall back to operating the DingTalk desktop UI unless the user explicitly asks for UI operation.

Before calling any DingTalk MCP tool, inspect its schema. Prefer the currently configured DingTalk calendar MCP server. In this environment it is commonly named `dingtalk-calendar-mcp`; older skills may mention `user-dingding-calendar-mcp`, but do not require that exact server name.

Use whichever loaded MCP server exposes these calendar operations:

- `query_busy_status`
- `query_available_meeting_room`
- `create_calendar_event`
- `add_meeting_room`
- `add_calendar_participant`
- `list_suggested_event_times`
- `list_calendar_events`

For attendee lookup, use the DingTalk contacts MCP service when available. In this environment it is commonly named `dingtalk-contacts-mcp`. Inspect the contacts tool schema first, search invitees by the user's supplied names, phone numbers, emails, or other clues, and use the returned supported participant identifiers such as `userId` or `openDingTalkId` when creating the meeting or adding participants.

If no DingTalk calendar MCP tools are available in the current conversation, stop and tell the user that the MCP tools need to be reloaded or the conversation needs to be restarted with the rebuilt MCP configuration. Do not create the meeting through Computer Use as an automatic fallback.

## Time Parsing

Normalize Chinese date and time expressions before API calls:

- `今天下午3点` -> today's date at `15:00`
- `明天上午10点半` -> tomorrow at `10:30`
- `晚上8点` -> `20:00`
- `半小时` -> `30 minutes`
- `1.5小时` -> `90 minutes`

End time priority:

1. explicit end time
2. explicit duration
3. default `30 minutes`

Convert the final start and end time to ISO-8601 with `+08:00`.

If a relative date/time is already in the past and the intent is unclear, ask one concise clarification question instead of guessing.

## Attendee Resolution

Resolve invited people before creating the event.

Rules:

- Use `dingtalk-contacts-mcp` to look up every requested invitee before creating the calendar event.
- Add resolved contacts to the meeting by passing their supported DingTalk identifiers to `create_calendar_event` or `add_calendar_participant`.
- Do not assume a plain Chinese name can be passed directly to calendar APIs.
- Do not assume DingTalk AI-style `@Name` mentions can be passed directly to structured MCP fields.
- Prefer exact DingTalk user identifiers returned by lookup tools.
- Reuse identifiers from previous DingTalk tool results in the same conversation when reliable.
- If several people share the same name, ask for distinguishing information.
- If attendee identifiers cannot be resolved, default to creating the meeting without those unresolved attendees instead of blocking, as long as the time and room can be handled.
- If only some attendees can be resolved, create the meeting with the resolved attendees and list unresolved attendees as pending follow-up.
- Never claim unresolved attendees were invited. The final response must clearly list them under `待补充`.

Known DingTalk calendar MCP nuance:

- `list_suggested_event_times` may accept plain names or `@Name` strings for availability recommendation, but this does not prove those strings can be used to invite attendees.
- `create_calendar_event.attendees` expects userId values; `create_calendar_event.openDingTalkIds` expects openDingTalkId values.
- `add_calendar_participant.attendeesToAdd` expects userId values and may return `user id is required` if given names or `@Name` strings.
- After creating a meeting with attendees, verify the returned `attendees` list or call `get_calendar_participants` when available. If requested attendees are missing, keep the meeting unless the user asked otherwise, and tell the user it was created without those attendees.
- The DingTalk desktop AI/assistant natural-language entry point may support `@Name` resolution, but only use Computer Use for that path when the user explicitly asks for UI operation; confirm before sending a command that can create or modify a real calendar event.

Use the number of invited people plus the organizer, when known, as the room capacity target. If the organizer count is uncertain, rank rooms by the invited attendee count and prefer one slightly larger room over one too small.

## Automatic Room Selection

The user explicitly wants the assistant to decide the meeting room automatically.

Workflow:

1. Call `query_available_meeting_room` for the final time range.
2. Filter to rooms available for the full meeting duration.
3. Rank rooms by capacity fit for attendee count:
   - prefer the smallest room whose capacity is at least the attendee count
   - for `1-4` attendees, prefer small rooms
   - for `5-8` attendees, prefer medium rooms
   - for `9+` attendees, prefer larger rooms
4. Use facilities as a tiebreaker when available:
   - prefer `Video Conference`, `TV`, or `Projector` for meetings with more than two attendees
5. If no room has capacity metadata, choose the first available room returned by DingTalk and state that capacity data was unavailable.
6. If no room is available, create the meeting without a room only after telling the user and asking whether to continue or choose another time.

Do not ask the user to choose a room unless every suitable room is unavailable or the API result is ambiguous enough that automatic selection would be unreliable.

## Creation Workflow

1. Parse the user request into title, time range, and invitees.
2. Apply defaults for omitted optional fields.
3. Use `dingtalk-contacts-mcp` to resolve attendees to DingTalk identifiers when possible; keep unresolved invitees as pending attendees.
4. Check organizer/calendar conflicts for the target time with `list_calendar_events` or `query_busy_status` when available.
5. If there is a conflict, tell the user the conflicting event title/time and ask whether to keep both or reschedule.
6. Query available rooms and choose one using the Automatic Room Selection rules.
7. Call `create_calendar_event` with the resolved title, time, reminder, room, and any resolved attendees. If no attendees are resolved, create the event without attendees.
8. If participants are not supported inline or some must be added separately, call `add_calendar_participant`.
9. Call `add_meeting_room` for the selected room.
10. Return the final result in the output template.

## Output Template

Use this structure after the meeting is created:

```markdown
会议已预约。

- 会议名称：`<title>`
- 时间：`<date and time>`
- 会议室：`<room name or 未预订>`
- 已邀请：`<resolved attendees>`
- 待补充：`<unresolved attendees or 无>`
- 入会信息：`<meeting code or room info if available>`
- 链接：<meeting link if available>
```

If a room or attendee could not be handled, state exactly what is missing and the smallest next step.

## Example Requests

- `$预约会议，今天下午3点，邀请张三、李四`
- `$预约会议，明天10:00-11:00，邀请产品组王五和研发赵六，会议名称：需求评审`
- `$预约会议，下周一下午2点半，邀请刘洋、陈晨、周宁`

---
name: reserve-dingtalk-meeting
description: 根据会议时间和参会人自动创建钉钉会议，默认补充会议标题，查询并预订合适会议室，邀请参会人并返回会议详情。
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

## Required dws Commands

All operations go through the `dws` CLI. Do not use MCP tools or the DingTalk desktop UI unless the user explicitly asks for UI operation.

Before constructing any command, use `dws schema <path>` to confirm parameter names, required fields, and flag aliases when uncertain.

Commands used in this workflow:

| Step | dws Command | Purpose |
|------|-------------|---------|
| 1 | `dws contact user search --query "<name>" --format json` | Resolve attendee names to `userId` |
| 2 | `dws calendar busy search --users <userIds> --start <ISO> --end <ISO> --format json` | Check organizer/attendee conflicts |
| 3 | `dws calendar event suggest --users <userIds> --start <ISO> --end <ISO> --duration <min> --format json` | Recommend free time slots |
| 4 | `dws calendar room search --start <ISO> --end <ISO> --available --format json` | Find available meeting rooms |
| 5 | `dws calendar event create --title ... --start ... --end ... --attendees ... --format json` | Create the event with attendees |
| 6 | `dws calendar participant add --event <eventId> --users <userIds> --format json` | Add participants separately if needed |
| 7 | `dws calendar room add --event <eventId> --rooms <roomId> --format json` | Book the selected room |

All commands must include `--format json` for machine-readable output.

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

- Use `dws contact user search --query "<name>" --format json` to look up every requested invitee.
- Parse the JSON output: the result array is at `result[].` with fields `userId`, `name`, `openDingTalkId`.
- Add resolved contacts to the meeting by passing their `userId` values to `dws calendar event create --attendees` (comma-separated) or to `dws calendar participant add --users`.
- Do not assume a plain Chinese name can be passed directly to calendar commands.
- Prefer exact `userId` values returned by the search command.
- Reuse identifiers from previous dws results in the same conversation when reliable.
- If several people share the same name, ask for distinguishing information.
- If attendee identifiers cannot be resolved, default to creating the meeting without those unresolved attendees instead of blocking, as long as the time and room can be handled.
- If only some attendees can be resolved, create the meeting with the resolved attendees and list unresolved attendees as pending follow-up.
- Never claim unresolved attendees were invited. The final response must clearly list them under `待补充`.

Known dws nuance:

- `dws calendar event suggest` may accept plain names in its `--users` field, but this does not prove those strings can be used to invite attendees.
- `dws calendar event create --attendees` expects `userId` values (comma-separated).
- `dws calendar participant add --users` expects `userId` values and may fail if given plain names.
- After creating a meeting, verify the returned attendees list. If requested attendees are missing, keep the meeting unless the user asked otherwise, and tell the user it was created without those attendees.
- The DingTalk desktop AI/assistant natural-language entry point may support `@Name` resolution, but only use Computer Use for that path when the user explicitly asks for UI operation; confirm before sending a command that can create or modify a real calendar event.

Use the number of invited people plus the organizer, when known, as the room capacity target. If the organizer count is uncertain, rank rooms by the invited attendee count and prefer one slightly larger room over one too small.

## Automatic Room Selection

The user explicitly wants the assistant to decide the meeting room automatically.

Workflow:

1. Run `dws calendar room search --start <ISO> --end <ISO> --available --format json` for the final time range.
2. Parse the JSON: available rooms are in `result.result[]` (note the nested `result` structure). Each room has `roomId`, `roomName`, `capacity`, `labels`.
3. Filter to rooms available for the full meeting duration (the `--available` flag already handles this).
4. Rank rooms by capacity fit for attendee count:
   - prefer the smallest room whose capacity is at least the attendee count
   - for `1-4` attendees, prefer small rooms
   - for `5-8` attendees, prefer medium rooms
   - for `9+` attendees, prefer larger rooms
5. Use facilities as a tiebreaker when available:
   - prefer rooms with `视频会议` (Video Conference), `电视` (TV), or `投影仪` (Projector) for meetings with more than two attendees
6. If no room has capacity metadata, choose the first available room returned and state that capacity data was unavailable.
7. If no room is available, create the meeting without a room only after telling the user and asking whether to continue or choose another time.

Do not ask the user to choose a room unless every suitable room is unavailable or the API result is ambiguous enough that automatic selection would be unreliable.

## Creation Workflow

1. Parse the user request into title, time range, and invitees.
2. Apply defaults for omitted optional fields.
3. Use `dws contact user search` to resolve attendees to DingTalk `userId` values; keep unresolved invitees as pending attendees.
4. Check organizer/calendar conflicts for the target time with `dws calendar event list` or `dws calendar busy search` when available.
5. If there is a conflict, tell the user the conflicting event title/time and ask whether to keep both or reschedule.
6. Query available rooms with `dws calendar room search --available` and choose one using the Automatic Room Selection rules.
7. Call `dws calendar event create` with the resolved title, time, and resolved attendees via `--attendees`.
   ```bash
   dws calendar event create \
     --title "<title>" \
     --start "<ISO-start>" --end "<ISO-end>" \
     --attendees "<userId1>,<userId2>" \
     --desc "<description>" \
     --format json
   ```
8. Extract the created event ID from the JSON response (check `result.id` or `result.eventId`).
9. Call `dws calendar room add --event <eventId> --rooms <roomId> --format json` to book the selected room.
10. If any attendees could not be added in step 7, call `dws calendar participant add --event <eventId> --users <userIds> --format json`.
11. Return the final result in the output template.

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

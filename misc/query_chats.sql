SELECT
    CASE m.type & 0x1f
    WHEN 1 THEN 'Empfangener Anruf'
    WHEN 2 THEN 'Ausgehender Anruf'
    WHEN 3 THEN 'Entgangener Sprachanruf'
    WHEN 4 THEN 'JOINED_TYPE'
    WHEN 5 THEN 'UNSUPPORTED_MESSAGE_TYPE'
    WHEN 6 THEN 'INVALID_MESSAGE_TYPE'
    WHEN 7 THEN 'PROFILE_CHANGE_TYPE'
    WHEN 8 THEN 'MISSED_VIDEO_CALL_TYPE'
    WHEN 9 THEN 'GV1_MIGRATION_TYPE'
    WHEN 10 THEN 'INCOMING_VIDEO_CALL_TYPE'
    WHEN 11 THEN 'OUTGOING_VIDEO_CALL_TYPE'
    WHEN 12 THEN 'GROUP_CALL_TYPE'
    WHEN 20 THEN 'Empfangene Nachricht'
    WHEN 21 THEN 'BASE_OUTBOX_TYPE'
    WHEN 22 THEN 'BASE_SENDING_TYPE'
    WHEN 23 THEN 'Gesendete Nachricht'
    WHEN 24 THEN 'BASE_SENT_FAILED_TYPE'
    WHEN 25 THEN 'BASE_PENDING_SECURE_SMS_FALLBACK'
    WHEN 26 THEN 'BASE_PENDING_INSECURE_SMS_FALLBACK'
    WHEN 27 THEN 'BASE_DRAFT_TYPE'
    ELSE '*UNKNOWN*'
    END typ,
    'sms_' || m._id as ID,
    datetime(m.date_sent/1000, 'unixepoch', 'localtime') as Datum,
    -- g.recipient_id as recipient_id,
    g.title,
    -- r._id as recipient_id,
    iif(g._id IS NOT NULL,
        g.title,
        iif(m.date_server == -1, '* Ich *', r.system_display_name)
    ) as sender,
    iif(g._id IS NOT NULL,
        'Gruppenchat',
        iif(m.date_server == -1, NULL, r.phone)
    ) as phone,
    m.body,
    NULL as attachment,
    m.type & 0x1f as type_code,
    NULL as content_type,
    NULL as content_size,
    NULL as content_dimension,
    t._id as thread_id
FROM
    thread AS t
    JOIN sms AS m
        ON ( m.thread_id = t._id )
    JOIN recipient r
        ON ( r._id = t.thread_recipient_id )
    LEFT JOIN groups g
        ON ( g.recipient_id = r._id )
WHERE 1
--    AND r._id = 90

UNION

SELECT
    CASE m.m_type & 0x1f
        WHEN 0 THEN 'Gesendete Medien'
        WHEN 1 THEN 'OUTGOING_TEXT'
        WHEN 2 THEN 'INCOMING_MULTIMEDIA'
        WHEN 3 THEN 'INCOMING_TEXT'
        WHEN 4 THEN 'UPDATE'
        WHEN 5 THEN 'HEADER'
        WHEN 6 THEN 'FOOTER'
        WHEN 7 THEN 'PLACEHOLDER'
        ELSE '*UNKNOWN*'
    END typ,
    'mms_' || m._id as ID,
    datetime(m.date/1000, 'unixepoch', 'localtime') as Datum,
    r._id as recipient_id,
    iif(g._id IS NOT NULL,
        g.title,
        iif(m.date_server == -1, '* Ich *', r.system_display_name)
    ) as sender,
    iif(g._id IS NOT NULL,
        'Gruppenchat',
        iif(m.date_server == -1, NULL, r.phone)
    ) as phone,
    m.body,
    p.unique_id || '_' || p._id || CASE p.ct
       WHEN 'image/jpeg' THEN '.jpg'
       WHEN 'video/mp4' THEN '.mp4'
       ELSE ''
    END AS attachment,
    m.m_type & 0x1f as type_code,
    p.ct as content_type,
    p.data_size as content_size,
    p.width || ' x ' || p.height as content_dimension,
    t._id as thread_id
FROM
    thread AS t
    JOIN mms AS m
        ON ( m.thread_id = t._id )
    JOIN recipient r
        ON ( r._id = t.thread_recipient_id )
    LEFT JOIN groups g
        ON ( g.recipient_id = r._id )
    LEFT JOIN part p
        ON ( p.mid = m._id )
WHERE 1
--    AND r._id = 90
ORDER BY
    thread_id,
    Datum
    ;


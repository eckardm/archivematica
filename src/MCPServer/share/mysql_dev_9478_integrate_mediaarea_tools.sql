-- Create the FPR tool, command, and rule rows needed for issue #9478:
-- MediaArea Tools Integration.
SET @tool_uuid = 'f79c56f1-2d42-440a-8a1f-f40888e24bca' COLLATE utf8_unicode_ci;
SET @command_uuid = '287656fb-e58f-4967-bf72-0bae3bbb5ca8' COLLATE utf8_unicode_ci;
SET @rule_uuid = 'a2fb0477-6cde-43f8-a1c9-49834913d588' COLLATE utf8_unicode_ci;
INSERT INTO `fpr_fptool` (`uuid`, `description`, `version`, `enabled`, `slug`) VALUES (@tool_uuid,'MediaConch','16.05',1,'mediaconch-1605');
INSERT INTO `fpr_fpcommand` (`replaces_id`, `enabled`, `lastmodified`, `uuid`, `tool_id`, `description`, `command`, `script_type`, `output_location`, `output_format_id`, `command_usage`, `verification_command_id`, `event_detail_command_id`) VALUES (NULL,1,'2016-07-04 23:39:31',@command_uuid, @tool_uuid, 'Validate using MediaConch', 'import json\nimport subprocess\nimport sys\nimport uuid\n\nfrom lxml import etree\n\nclass MediaConchException(Exception):\n    pass\n\nNS = \'{https://mediaarea.net/mediaconch}\'\n\ndef parse_mediaconch_data(target):\n    \"\"\"Run `mediaconch -mc -iv 4 -fx <target>` against `target` and return an\n    lxml etree parse of the output.\n\n    .. note::\n\n        At present, MediaConch (v. 16.05) will give terse output so long as you\n        provide *some* argument to the -iv option. With no -iv option, you will\n        get high verbosity. To be specific, low verbosity means that only\n        checks whose tests fail in the named \"MediaConch EBML Implementation\n        Checker\" will be displayed. If none fail, the EBML element will contain\n        no <check> elements.\n\n    \"\"\"\n\n    args = [\'mediaconch\', \'-mc\', \'-iv\', \'4\', \'-fx\', target]\n    try:\n        output = subprocess.check_output(args)\n    except subprocess.CalledProcessError:\n        raise JhoveException(\"MediaConch failed when running: %s\" % (\n            \' \'.join(args),))\n    return etree.fromstring(output)\n\n\ndef get_impl_check_name(impl_check_el):\n    name_el = impl_check_el.find(\'%sname\' % NS)\n    if name_el is not None:\n        return name_el.text\n    else:\n        return \'Unnamed Implementation Check %s\' % uuid.uuid4()\n\n\ndef get_check_name(check_el):\n    return check_el.attrib.get(\'name\',\n        check_el.attrib.get(\'icid\', \'Unnamed Check %s\' % uuid.uuid4()))\n\n\ndef get_check_tests_outcomes(check_el):\n    \"\"\"Return a list of outcome strings for the <check> element `check_el`.\"\"\"\n    outcomes = []\n    for test_el in check_el.iterfind(\'%stest\' % NS):\n        outcome = test_el.attrib.get(\'outcome\')\n        if outcome:\n            outcomes.append(outcome)\n    return outcomes\n\n\ndef get_impl_check_result(impl_check_el):\n    \"\"\"Return a dict mapping check names to lists of test outcome strings.\"\"\"\n\n    checks = {}\n    for check_el in impl_check_el.iterfind(\'%scheck\' % NS):\n        check_name = get_check_name(check_el)\n        test_outcomes = get_check_tests_outcomes(check_el)\n        if test_outcomes:\n            checks[check_name] = test_outcomes\n    return checks\n\n\ndef get_impl_checks(doc):\n    \"\"\"When not provided with a policy file, MediaConch produces a series of\n    XML <implementationChecks> elements that contain <check> sub-elements. This\n    function returns a dict mapping implementation check names to dicts that\n    map individual check names to lists of test outcomes, i.e., \'pass\' or\n    \'fail\'.\n\n    \"\"\"\n\n    impl_checks = {}\n    path = \'.%smedia/%simplementationChecks\' % (NS, NS)\n    for impl_check_el in doc.iterfind(path):\n        impl_check_name = get_impl_check_name(impl_check_el)\n        impl_check_result = get_impl_check_result(impl_check_el)\n        if impl_check_result:\n            impl_checks[impl_check_name] = impl_check_result\n    return impl_checks\n\n\ndef get_event_outcome_information_detail(impl_checks):\n    \"\"\"Return a 2-tuple of info and detail.\n\n    - info: \'pass\' or \'fail\'\n    - detail: human-readable string indicating which implementation checks\n      passed or failed. If implementation check as a whole passed, just return\n      the passed check names; if it failed, just return the failed ones.\n\n    \"\"\"\n\n    info = \'pass\'\n    failed_impl_checks = []\n    passed_impl_checks = []\n    for impl_check, checks in impl_checks.iteritems():\n        passed_checks = []\n        failed_checks = []\n        for check, outcomes in checks.iteritems():\n            for outcome in outcomes:\n                if outcome == \'pass\':\n                    passed_checks.append(check)\n                else:\n                    info = \'fail\'\n                    failed_checks.append(check)\n        if failed_checks:\n            failed_impl_checks.append(\'The implementation check %s returned\'\n                \' failure for the following check(s): %s.\' % (impl_check,\n                \', \'.join(failed_checks)))\n        else:\n            passed_impl_checks.append(\'The implementation check %s returned\'\n                \' success for the following check(s): %s.\' % (impl_check,\n                \', \'.join(passed_checks)))\n    if info == \'pass\':\n        if passed_impl_checks:\n            return info, \' \'.join(passed_impl_checks)\n        return info, \'All checks passed.\'\n    else:\n        return info, \' \'.join(failed_impl_checks)\n\n\ndef main(target):\n    \"\"\"Return 0 if MediaConch can successfully assess whether the file at\n    `target` is a valid Matroska (.mkv) file. Parse the XML output by\n    MediaConch and print a JSON representation of that output.\n\n    \"\"\"\n\n    try:\n        doc = parse_mediaconch_data(target)\n        impl_checks = get_impl_checks(doc)\n        info, detail = get_event_outcome_information_detail(impl_checks)\n        print json.dumps({\n            \'eventOutcomeInformation\': info,\n            \'eventOutcomeDetailNote\': detail\n        })\n        return 0\n    except MediaConchException as e:\n        return e\n\n\nif __name__ == \'__main__\':\n    target = sys.argv[1]\n    sys.exit(main(target))\n\n','pythonScript',NULL,NULL,'validation',NULL,NULL);
SELECT uuid INTO @matroska_format_uuid FROM fpr_formatversion WHERE description = 'Generic MKV';
INSERT INTO `fpr_fprule` (`replaces_id`, `enabled`, `lastmodified`, `uuid`, `purpose`, `command_id`, `format_id`, `count_attempts`, `count_okay`, `count_not_okay`) VALUES (NULL, 1, '2016-06-29 22:04:08', @rule_uuid, 'validation', @command_uuid, @matroska_format_uuid, 0, 0, 0);
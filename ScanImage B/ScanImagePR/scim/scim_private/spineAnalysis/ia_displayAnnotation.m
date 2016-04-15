%TO080707A - Display annotation to the console in a readable/copyable format.
function ia_displayAnnotation(annotation)

if length(annotation) > 1
    fprintf(1, '%s array of annotations...\n', num2str(length(annotation)));
    for i = 1 : length(annotation)
        ia_displayAnnotation(annotation(i));
    end
    return;
end
fprintf(1, 'annotation.type = ''%s''\n', annotation.type);
fprintf(1, 'annotation.x = %s\n', mat2str(annotation.x));
fprintf(1, 'annotation.y = %s\n', mat2str(annotation.y));
fprintf(1, 'annotation.z = %s\n', mat2str(annotation.z));
fprintf(1, 'annotation.tag = ''%s''\n', annotation.tag);
fprintf(1, 'annotation.autoID = ''%s''\n', num2str(annotation.autoID));
fprintf(1, 'annotation.userID = ''%s''\n', annotation.userID);
fprintf(1, 'annotation.text = ''%s''\n', annotation.text);
fprintf(1, 'annotation.correlationID = ''%s''\n', num2str(annotation.correlationID));
fprintf(1, 'annotation.correlationState = ''%s''\n', annotation.correlationState);
switch (annotation.persistence)
    case 1
        fprintf(1, 'annotation.persistence = STABLE (1)\n');
    case 2
        fprintf(1, 'annotation.persistence = LOSS (2)\n');
    case 3
        fprintf(1, 'annotation.persistence = GAIN (3)\n');
    case 2
        fprintf(1, 'annotation.persistence = TRANSIENT (4)\n');
    case 3
        fprintf(1, 'annotation.persistence = NEUTRAL (5)\n');
    otherwise
        fprintf(1, 'annotation.persistence = %s\n', num2str(annotation.persistence));
end
fprintf(1, 'annotation.creationTime = ''%s''\n', datestr(annotation.creationTime));
fprintf(1, 'annotation.userData.type = ''%s''\n', annotation.userData.type);
fprintf(1, 'annotation.filename = ''%s''\n', annotation.filename);
fprintf(1, 'annotation.channel = ''%s''\n', num2str(annotation.channel));
if isfield(annotation, 'photometry')
    if isempty(annotation.photometry)
        fprintf(1, 'annotation.photometry = []\n');
    else
        for i = 1 : length(annotation.photometry)
            fprintf(1, 'annotation.photometry(%s).background = %s\n', num2str(i), num2str(annotation.photometry(i).background));
            fprintf(1, 'annotation.photometry(%s).backgroundBounds = %s\n', num2str(i), mat2str(annotation.photometry(i).backgroundBounds));
            fprintf(1, 'annotation.photometry(%s).backgroundFrame = %s\n', num2str(i), num2str(annotation.photometry(i).backgroundFrame));
            fprintf(1, 'annotation.photometry(%s).backgroundChannel = %s\n', num2str(i), num2str(annotation.photometry(i).backgroundChannel));
            fprintf(1, 'annotation.photometry(%s).normalization = %s\n', num2str(i), num2str(annotation.photometry(i).normalization));
            fprintf(1, 'annotation.photometry(%s).normalizationBounds = %s\n', num2str(i), mat2str(annotation.photometry(i).normalizationBounds));
            fprintf(1, 'annotation.photometry(%s).normalizationFrame = %s\n', num2str(i), num2str(annotation.photometry(i).normalizationFrame));
            fprintf(1, 'annotation.photometry(%s).normalizationMethod = %s\n', num2str(i), mat2str(annotation.photometry(i).normalizationMethod));
            fprintf(1, 'annotation.photometry(%s).normalizationChannel = %s\n', num2str(i), num2str(annotation.photometry(i).normalizationChannel));
            fprintf(1, 'annotation.photometry(%s).integral = %s\n', num2str(i), num2str(annotation.photometry(i).integral));
            fprintf(1, 'annotation.photometry(%s).integralBounds = %s\n', num2str(i), mat2str(annotation.photometry(i).integralBounds));
            fprintf(1, 'annotation.photometry(%s).integralFrame = %s\n', num2str(i), num2str(annotation.photometry(i).integralFrame));
            fprintf(1, 'annotation.photometry(%s).integralChannel = %s\n', num2str(i), num2str(annotation.photometry(i).integralChannel));
        end
    end
end
fprintf(1, '\n');

return;
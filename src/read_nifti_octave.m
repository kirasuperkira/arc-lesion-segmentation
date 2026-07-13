function [img, info] = read_nifti_octave(filename)
    fid = fopen(filename, 'r');
    if fid == -1
        error('Could not open file: %s', filename);
    end

    header = fread(fid, 348, 'uint8=>uint8');
    fclose(fid);

    magic = char(header(345:348)');
    if ~ismember(magic, {'n+1', 'ni1'})
        warning('Invalid Magic number: %s', magic);
    end

    dim = typecast(header(41:48), 'int16');
    ndims_data = dim(1);
    shape = dim(2:ndims_data+1)';

    datatype = header(71);

    switch datatype
        case 2, precision = 'uint8=>uint8';
        case 4, precision = 'int16=>int16';
        case 8, precision = 'int32=>int32';
        case 16, precision = 'float32=>single';
        case 64, precision = 'float64=>double';
        otherwise
            precision = 'uint8=>uint8';
            warning('Unknown data type: %d', datatype);
    end

    fid = fopen(filename, 'r');
    fseek(fid, 348, 'bof');
    img = fread(fid, prod(shape), precision);
    fclose(fid);

    img = reshape(img, shape);

    info.dim = shape;
    info.datatype = datatype;
    info.magic = magic;
end

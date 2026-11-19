#include <librealsense2/rs.h>
#include <librealsense2-gl/rs_processing_gl.h>

int main()
{
    rs2_error* e = nullptr;
    /* Reference symbols from both libraries so that linking needs both. */
    auto gl = &rs2_gl_create_yuy_decoder;
    return rs2_get_api_version(&e) > 0 && gl ? 0 : 1;
}

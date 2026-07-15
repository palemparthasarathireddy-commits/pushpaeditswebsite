import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase, VideoRecord } from '../lib/supabase';
import { toast } from 'sonner';

export const useVideos = () => {
  const queryClient = useQueryClient();

  // Fetch Videos
  const { data: videos = [], isLoading } = useQuery({
    queryKey: ['videos'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('videos')
        .select('*')
        .order('created_at', { ascending: false });

      if (error) throw error;
      return data as VideoRecord[];
    },
  });

  // Add Video
  const addVideo = useMutation({
    mutationFn: async (newVideo: Omit<VideoRecord, 'id' | 'created_at'>) => {
      const { data, error } = await supabase
        .from('videos')
        .insert([newVideo])
        .select()
        .single();

      if (error) throw error;
      return data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['videos'] });
      toast.success('Video uploaded successfully!');
    },
    onError: (error: any) => {
      toast.error(`Failed to save video metadata: ${error.message}`);
    },
  });

  // Delete Video
  const deleteVideo = useMutation({
    mutationFn: async (id: string) => {
      const { error } = await supabase.from('videos').delete().eq('id', id);
      if (error) throw error;
      return id;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['videos'] });
      toast.success('Video deleted successfully!');
    },
    onError: (error: any) => {
      toast.error(`Failed to delete video: ${error.message}`);
    },
  });

  return { videos, isLoading, addVideo, deleteVideo };
};
